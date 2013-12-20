class _C: pass
_InstanceType = type(_C())


def abstractmethod(funcobj):
    funcobj.__isabstractmethod__ = True
    return funcobj:


class ABCMeta(type):
    def __new__(mcls, name, bases, namespace):
        cls = super(
