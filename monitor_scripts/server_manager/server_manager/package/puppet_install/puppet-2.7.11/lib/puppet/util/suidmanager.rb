require 'puppet/util/warnings'
require 'forwardable'
require 'etc'

module Puppet::Util::SUIDManager
  include Puppet::Util::Warnings
  extend Forwardable

  # Note groups= is handled specially due to a bug in OS X 10.6, 10.7,
  # and probably upcoming releases...
  to_delegate_to_process = [ :euid=, :euid, :egid=, :egid, :uid=, :uid, :gid=, :gid, :groups ]

  to_delegate_to_process.each do |method|
    def_delegator Process, method
    module_function method
  end

  def osx_maj_ver
    return @osx_maj_ver unless @osx_maj_ver.nil?
    require 'facter'
    # 'kernel' is available without explicitly loading all facts
    if Facter.value('kernel') != 'Darwin'
      @osx_maj_ver = false
      return @osx_maj_ver
    end
    # But 'macosx_productversion_major' requires it.
    Facter.loadfacts
    @osx_maj_ver = Facter.value('macosx_productversion_major')
  end
  module_function :osx_maj_ver

  def groups=(grouplist)
    begin
      return Process.groups = grouplist
    rescue Errno::EINVAL => e
      #We catch Errno::EINVAL as some operating systems (OS X in particular) can
      # cause troubles when using Process#groups= to change *this* user / process
      # list of supplementary groups membership.  This is done via Ruby's function
      # "static VALUE proc_setgroups(VALUE obj, VALUE ary)" which is effectively
      # a wrapper for "int setgroups(size_t size, const gid_t *list)" (part of SVr4
      # and 4.3BSD but not in POSIX.1-2001) that fails and sets errno to EINVAL.
      #
      # This does not appear to be a problem with Ruby but rather an issue on the
      # operating system side.  Therefore we catch the exception and look whether
      # we run under OS X or not -- if so, then we acknowledge the problem and
      # re-throw the exception otherwise.
      if osx_maj_ver and not osx_maj_ver.empty?
        return true
      else
        raise e
      end
    end
  end
  module_function :groups=

  def self.root?
    return Process.uid == 0 unless Puppet.features.microsoft_windows?

    require 'sys/admin'
    require 'win32/security'
    require 'facter'

    majversion = Facter.value(:kernelmajversion)
    return false unless majversion

    # if Vista or later, check for unrestricted process token
    return Win32::Security.elevated_security? unless majversion.to_f < 6.0

    group = Sys::Admin.get_group("Administrators", :sid => Win32::Security::SID::BuiltinAdministrators)
    group and group.members.index(Sys::Admin.get_login) != nil
  end

  # Methods to handle changing uid/gid of the running process. In general,
  # these will noop or fail on Windows, and require root to change to anything
  # but the current uid/gid (which is a noop).

  # Runs block setting euid and egid if provided then restoring original ids.
  # If running on Windows or without root, the block will be run with the
  # current euid/egid.
  def asuser(new_uid=nil, new_gid=nil)
    return yield if Puppet.features.microsoft_windows?
    return yield unless root?
    return yield unless new_uid or new_gid

    old_euid, old_egid = self.euid, self.egid
    begin
      change_privileges(new_uid, new_gid, false)

      yield
    ensure
      change_privileges(new_uid ? old_euid : nil, old_egid, false)
    end
  end
  module_function :asuser

  # If `permanently` is set, will permanently change the uid/gid of the
  # process. If not, it will only set the euid/egid. If only uid is supplied,
  # the primary group of the supplied gid will be used. If only gid is
  # supplied, only gid will be changed. This method will fail if used on
  # Windows.
  def change_privileges(uid=nil, gid=nil, permanently=false)
    return unless uid or gid

    unless gid
      uid = convert_xid(:uid, uid)
      gid = Etc.getpwuid(uid).gid
    end

    change_group(gid, permanently)
    change_user(uid, permanently) if uid
  end
  module_function :change_privileges

  # Changes the egid of the process if `permanently` is not set, otherwise
  # changes gid. This method will fail if used on Windows, or attempting to
  # change to a different gid without root.
  def change_group(group, permanently=false)
    gid = convert_xid(:gid, group)
    raise Puppet::Error, "No such group #{group}" unless gid

    if permanently
      Process::GID.change_privilege(gid)
    else
      Process.egid = gid
    end
  end
  module_function :change_group

  # As change_group, but operates on uids. If changing user permanently,
  # supplementary groups will be set the to default groups for the new uid.
  def change_user(user, permanently=false)
    uid = convert_xid(:uid, user)
    raise Puppet::Error, "No such user #{user}" unless uid

    if permanently
      # If changing uid, we must be root. So initgroups first here.
      initgroups(uid)

      Process::UID.change_privilege(uid)
    else
      # We must be root to initgroups, so initgroups before dropping euid if
      # we're root, otherwise elevate euid before initgroups.
      # change euid (to root) first.
      if Process.euid == 0
        initgroups(uid)
        Process.euid = uid
      else
        Process.euid = uid
        initgroups(uid)
      end
    end
  end
  module_function :change_user

  # Make sure the passed argument is a number.
  def convert_xid(type, id)
    map = {:gid => :group, :uid => :user}
    raise ArgumentError, "Invalid id type #{type}" unless map.include?(type)
    ret = Puppet::Util.send(type, id)
    if ret == nil
      raise Puppet::Error, "Invalid #{map[type]}: #{id}"
    end
    ret
  end
  module_function :convert_xid

  # Initialize primary and supplemental groups to those of the target user.  We
  # take the UID and manually look up their details in the system database,
  # including username and primary group. This method will fail on Windows, or
  # if used without root to initgroups of another user.
  def initgroups(uid)
    pwent = Etc.getpwuid(uid)
    Process.initgroups(pwent.name, pwent.gid)
  end

  module_function :initgroups

  def run_and_capture(command, new_uid=nil, new_gid=nil)
    output = Puppet::Util.execute(command, :failonfail => false, :combine => true, :uid => new_uid, :gid => new_gid)
    [output, $CHILD_STATUS.dup]
  end
  module_function :run_and_capture
end
