extends Resource

class_name CtxFRef2

var ref setget , _get_ref

var _f: FuncRef
var _ctx

func _init(f: FuncRef, ctx) -> void:
	_f = f
	_ctx = ctx

func call_func(x, y): return _f.call_func(x, y, _ctx)

func _get_ref(): return funcref(self, "call_func")
