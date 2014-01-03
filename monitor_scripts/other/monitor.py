#!/usr/local/bin/python
#-*- encoding:utf-8 -*-
import socket, select, struct, logging, smtplib, httplib, time
import threading
from urlparse import urlparse
from email.MIMEText import MIMEText

# config
log_file_name = 'monitor_bj.log'
mail_error_to = ['sunbx@funshion.com',]
#mail_error_to = ['OP@funshion.com', 'wubo@funshion.com']
mail_log_to = ['sunbx@funshion.com']
mail_subject_prefix = '北京机房'

LIST = {
    ##############################
    #监控广告AD/ADM
    (
        'http://ad.funshion.com/control/adredirect.html',
        'http://ad.funshion.com/control/ad_define.fai',
        'http://ad.funshion.com/pause/?c=shy,,',
        'http://adm.funshion.com/ad/2010-12/19CA07D0_07AE_9F44_52D2_481FAB1722F4.swf',
    ):[
        '220.181.167.62',  #kejie yz  vip
        '220.181.167.46',  #kejie yz  vip
        '220.181.167.52',  #kejie yz haproxy ip
        '220.181.167.53',  #kejie yz haproxy ip
        '220.181.167.54',  #kejie yz haproxy ip
        '220.181.167.55',  #kejie yz haproxy ip
        '220.181.167.56',  #kejie yz haproxy ip
    ],

    ##############################
    #监控hermes mc/pub/conf
    (
        'http://mc.funshion.com/interface/mc?mc=1',
        'http://mc.funshion.com/interface/cc?cc=1',
        'http://pub.funshion.com/interface/deliver?ap=c_b_1',
        'http://pub.funshion.com/interface/monitor?uid=&mac=&fck=9B9D1F39F94CD9D7E84FDFB413677674&ap=c_b_1&matid=530&ad=1795&mid=&reqId=b4251050-9772-11e2-a3ba-79461cd3ded8&t=',
        'http://pub.funshion.com/interface/materials?ap=c_b_1',
        'http://conf.funshion.com/interface/config?client=pc&file=pc-aconfig&ver=2.8.5.24&fmt=xml',
        'http://conf.funshion.com/interface/config?client=ipad&ver=2.8.5.24&fmt=json&file=ipad-aconfig',
    ):[
        '220.181.167.89',  #hermes yz  vip
        '220.181.167.90',  #hermes yz  vip
        '220.181.167.85',  #hermes yz haproxy ip
        '220.181.167.86',  #hermes yz haproxy ip
        '220.181.167.84',  #hermes yz haproxy ip
        '220.181.167.87',  #hermes yz haproxy ip
        '220.181.167.88',  #hermes yz haproxy ip
    ],
    ##############################

    #监控广告ADK
    (
        'http://adk.funshion.com/adpolestar/door/;ap=0C878E15_E043_1879_DB52_84F5AC60F6ED;ct=if;pu=funshion;/?',
    ):[
        '220.181.167.62',  #kejie yz  vip
        '220.181.167.46',  #kejie yz  vip
        '220.181.167.52',  #kejie yz haproxy ip
       '220.181.167.53',  #kejie yz haproxy ip
        '220.181.167.54',  #kejie yz haproxy ip
        '220.181.167.55',  #kejie yz haproxy ip
        '220.181.167.56',  #kejie yz haproxy ip
    ],

    ##############################
    #监控增值url
    (
        'http://game.funshion.com',
        'http://shop.funshion.com',
        'http://pay.funshion.com',
        'http://cms.funshion.com/door.php?source=desktop1',
    ):[
        #Beijing unicom lighttpd
        #'123.125.20.15',
        '114.66.198.22',
        #'123.125.20.42',
        '114.66.198.23',
        #Beijing unicom haproxy
        '123.125.20.18',
        '123.125.20.19',
        #Beijing telecom haproxy
        #'220.181.126.208',
        #'220.181.126.209',
    ],

    ##############################
    #监控北京电信/联通机房HAPROXY
    (
        'http://static.funshion.com/css/default.css?20101130',
        'http://fs.funshion.com/publish/first?ver=5',
        'http://www.funshion.com',
        'http://i.funshion.com',
        'http://api.funshion.com/embed_zone',
        'http://img.funshion.com/attachment/images/2008/08-04/5372255_1217833540_699_m.jpg',
        'http://jsonfe.funshion.com/list/?cli=iphone&ver=1.1.0.1&pagesize=20&type=movie&page=20',
        'http://push.funshion.com/api/reset_badge.php?devicetoken=(null)',

    ):[
        #'220.181.126.195',
        #'220.181.126.196',
        #'220.181.126.197',
        #'220.181.126.198',
        #'220.181.126.199',
        #'123.125.20.37',
        '123.125.20.38',
        '123.125.20.39',
#       '123.125.20.40',
        '220.181.167.6', #yz vip
        '220.181.167.7', #yz vip
        '220.181.167.8', #yz vip
        '220.181.167.9', #yz vip
        '220.181.167.20', #yz haproxy
        '220.181.167.21', #yz haproxy
        '220.181.167.14', #yz haproxy
        '220.181.167.16', #yz haproxy
        '220.181.167.19', #yz haproxy
    ],

    (
        'http://www.btstream.org/fsp/2012-02-02/23623226_1328165528_733.fsp',
        'http://imgb.funshion.com/fsp/2012-02-02/23623226_1328165528_733.fsp',
        'http://q.funshion.com/api/torrents/94114/cf01b79e2d80166/4862ef8ce74118f933c0b1a8bb285a0d6a78370a',
        'http://q.funshion.com/v5/getfsp/94209?h=1',
        'http://imgq.funshion.com/api/torrents/94114/cf01b79e2d80166/4862ef8ce74118f933c0b1a8bb285a0d6a78370a',
    ):[
        '220.181.167.6',
        '220.181.167.7',
        '220.181.167.8',
        '220.181.167.9',
    ],

    ##############################
    #partner.funshion.com
    (
        'http://partner.funshion.com/partner/install_statistic.php?s=001D7D3F57DF&id=&c=39e1b8fa03c0c1dcb41b5cc70dde2744&t=first&u=&v=2.3.0.16&auto=0&other=10000000100&mh=1&guid=A835EE1C906144559D6D0EFDF0976C33',
    ):[
        '123.125.20.58',
        #'220.181.126.208',
    ],

    #  xiaozhan
    (
        'http://www.midianying.com',
        'http://www.midianshi.com',
        'http://www.mizongyi.com',
        'http://www.miriju.com',
        'http://www.midongman.com',
        'http://www.mimeiju.com',
        'http://www.midianying.com/fsp/2009-09-16/5372255_1253080482_866.fsp'
        'http://www.midianying.com/img/misite/midianying.jpg'
    ):[
        '218.156.80.2',
    ],

    #SSO
    #(
    #    'http://sso.funshion.com/sso/remoteLogin?loginUrl=http%3A%2F%2Fgame.funshion.com%2Findex%2Faccount%2Findex.php%3Fc%3Dindex%26a%3Dglobal_login&service=http%3A%2F%2Fgame.funshion.com%2Findex%2Faccount%2Findex.php%3Fc%3Dindex%26a%3Dcheck_login%26cb%3DcheckCallback',
    #):[
    #    '123.125.20.12',
    #    '123.125.20.50',
    #    '220.181.167.6',
    #],

}

#config logging
logger = logging.getLogger()
hdlr = logging.FileHandler(log_file_name, 'w')
formatter = logging.Formatter('%(asctime)s %(levelname)s %(message)s')
hdlr.setFormatter(formatter)
logger.addHandler(hdlr)
logger.setLevel(logging.DEBUG)


class GET(threading.Thread):
    def __init__(self, url, ip):
        threading.Thread.__init__(self)
        self.url = url
        o = urlparse(self.url)
        self.hostname = o.hostname
        self.ip = ip
        if o.port:
            self.port = o.port
        else:
            self.port = 80

        if o.query == '':
            if o.path == '':
                self.request = '/'
            else:
                self.request = o.path
        else:
            self.request = o.path + '?' + o.query

    def run(self):
        try :
            http = httplib.HTTPConnection(self.ip, self.port)
            http.putrequest("GET", self.request, 1, 1)
            http.putheader("User-Agent", "Mozilla/4.0")
            http.putheader("Connection", "close")
            http.putheader("Accept-Encoding", "gzip, deflate")
            http.putheader("Host", self.hostname)
            http.putheader("Cache-Control", "no-cache")
            http.endheaders()   #endheaders()执行时才会开始建立尝试建立连接

            r = http.getresponse()
            if not r:
                logger.error("%s-%s:%s Fatal Error: http.getresponse(), impossible?" %(self.hostname, self.ip, self.port))

            if r.status >= 400:
                logger.error("%s-%s:%s Response: '%s %s'" % (self.hostname, self.ip, self.port, r.status, r.reason))
            elif r.status == 301 or r.status == 302:
                self.redirect = r.getheader('location')
                logger.info("%s-%s:%s Response: '%s %s'. Location: %s" % (self.hostname, self.ip, self.port, r.status, r.reason, self.redirect))
            else:
                logger.info("%s-%s:%s Response:'%s %s'" % (self.hostname, self.ip, self.port, r.status, r.reason))

        except Exception, e:
	    if e.errno == 110:
		pass
	    else:
            	logger.error("%s-%s:%s Fatal Error: %s" %(self.hostname, self.ip, self.port, e))


class WebServer(threading.Thread):
    def __init__(self, url, ip_list = None):
        threading.Thread.__init__(self)
        self.url = url
        self.ips = []
        #
        if ip_list == None:
            try :
                addrs = socket.getaddrinfo(urlparse(self.url).hostname, 'http', socket.AF_INET, socket.SOCK_STREAM)
            except Exception, e:
                logger.error("%s-%s, need check dns server." % (urlparse(self.url).hostname,e))
                addrs = []
            for addr in addrs:
                ip = addr[4][0]
                if ip in self.ips:
                    pass
                else:
                    self.ips.append(ip)
        else:
            self.ips = ip_list

    def run(self):
        threads = []
        #每个ip建立一个线程
        for ip in self.ips:
            g = GET(self.url, ip)
            threads.append(g)

        #依次启动所有线程
        for thread in threads:
            thread.start()

        #等待所有线程退出
        for thread in threads:
            thread.join()


class Mail(object):
    def __init__(self, filename, subject_prefix=''):
        self.fromaddr = 'jkfunshion@funshion.com'
        self.toaddrs = ''
        self.mailtype = 'ALL'
        self.filename = filename
        self.subject = ''
        self.subject_prefix = subject_prefix

    def sendmail(self, toaddrs, mailtype):
        f = open("%s" % self.filename, 'r')
        text = f.readlines()
        f.close()
        message = ''
        if mailtype == 'ERROR':
            self.subject = '%s服务异常！' % self.subject_prefix
            for line in text:
                if line.find('ERROR') >= 0:
                    message += line
        else:
            self.subject = '%s服务检查日志' % self.subject_prefix
            for line in text:
                message += line
        
        msg = MIMEText(message)
        msg['From'] = self.fromaddr
        msg['To'] = ','.join(toaddrs)
        msg['Subject'] = self.subject

        if len(message) !=0:
            try :
                server = smtplib.SMTP("mail.funshion.com")
                server.login('jkfunshion', 'jkmail%')
                server.sendmail(self.fromaddr, toaddrs, msg.as_string())
                server.quit()
            except Exception, e:
                logger.error(e)

def main():
    threads = []

    for domains in LIST.keys():
        ips = LIST[domains]
        for domain in domains:
            g = WebServer(domain, ips)
            threads.append(g)
    
    #依次启动所有线程
    for thread in threads:
        thread.start()

    #等待所有线程退出
    for thread in threads:
        thread.join()


def sendmail():
    #SendMail
    m = Mail(log_file_name, mail_subject_prefix)
    m.sendmail(mail_error_to, 'ERROR')
    m.sendmail(mail_log_to, 'ALL')


if __name__ == "__main__":
    main()
    sendmail()

