extends Resource

class_name FlowF

var _functions

func _init(functions: Array):
	_functions = functions

func call_func(x):
	var r = x
	for f in _functions: r = f.call_func(r)
	return r
