# Reference of a function which takes two arguments - current item or data, and context
# poor-languge's emulation of partial application

extends Resource

class_name CtxFRef1

var _f: FuncRef
var _ctx

func _init(f: FuncRef, ctx) -> void:
	_f = f
	_ctx = ctx

func call_func(x): return _f.call_func(x, _ctx)
