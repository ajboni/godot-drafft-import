extends Resource

class_name GGInternal

const _EMPTY_CONTEXT = "This is a workaround GDScript's limitations:" +\
  " instances of user classes cannot be assigned to const (nor anything like 'Symbol' from JS exists)"

func quit_(error_code: int = 0) -> void:
	var ml = Engine.get_main_loop()
	OS.set_exit_code(error_code)
	if !ml || !ml.has_method("quit"):
		print("Failed to get main loop (or it doesn't support quit method). Cannot use ordinary means of termination.")
		assert(false)
	else:
		ml.quit()

func crash_(msg: String) -> void:
	print("crash:", msg)
	quit_(1)

func assert_(cond: bool, msg: String) -> void: if !cond: crash_(msg)

func head_(arr: Array):
	if is_empty_(arr): crash_("Cannot get a first element (head) of an empty array.")
	return arr[0]

func head_or_null_(arr: Array):
	return arr[0] if !is_empty_(arr) else null

func last_(arr: Array):
	if is_empty_(arr): crash_("Cannot get a last element of an empty array")
	return arr[arr.size() - 1]

func last_or_null_(arr: Array):
	return arr[arr.size() - 1] if !is_empty_(arr) else null

func tail_(arr: Array):
	if is_empty_(arr): return null
	var r = arr.duplicate()
	r.pop_front()
	return r

func init_(arr: Array):
	if is_empty_(arr): return null
	var r = arr.duplicate()
	r.pop_back()
	return r

func map_fn_(arr: Array, f, ctx = _EMPTY_CONTEXT) -> Array:
	var r:= []
	for x in arr: r.push_back(call_f1_w_ctx(f, x, ctx))
	return r

func map_(arr: Array, f, ctx = _EMPTY_CONTEXT) -> Array: return map_fn_(arr, f_like_to_func(f), ctx)

func for_each_fn_(arr: Array, f, ctx = _EMPTY_CONTEXT) -> void: for x in arr: call_f1_w_ctx(f, x, ctx)

func for_each_(arr: Array, f, ctx = _EMPTY_CONTEXT) -> void: for_each_fn_(arr, f_like_to_func(f), ctx)

func join_(arr: Array, delim: String = "", before: String = "", after: String = "") -> String:
	return before + PoolStringArray(arr).join(delim) + after

func filter_fn_(arr: Array, predicate, ctx = _EMPTY_CONTEXT) -> Array:
	var r:= []
	for x in arr: if call_f1_w_ctx(predicate, x, ctx): r.push_back(x)
	return r

func filter_(arr: Array, predicate, ctx = _EMPTY_CONTEXT) -> Array: return filter_fn_(arr, f_like_to_func(predicate), ctx)

func find_(arr: Array, predicate, ctx = _EMPTY_CONTEXT): return head_(filter_(arr, predicate, ctx))

func find_or_null_(arr: Array, predicate, ctx = _EMPTY_CONTEXT): return head_or_null_(filter_(arr, predicate, ctx))

func find_index_or_null_(arr: Array, predicate, ctx = _EMPTY_CONTEXT):
	var p = f_like_to_func(predicate)
	for i in range(arr.size()):
		if call_f1_w_ctx(p, arr[i], ctx): return i
	return null

func find_index_(arr: Array, predicate, ctx = _EMPTY_CONTEXT):
	var r = find_index_or_null_(arr, predicate, ctx)
	assert_(r != null, "index not found")
	return r

func foldl_fn_(arr: Array, f: FuncRef, zero, ctx = _EMPTY_CONTEXT):
	var r = zero
	for x in arr: r = call_f2_w_ctx(f, r, x, ctx)
	return r

func foldl_(arr: Array, f, zero, ctx = _EMPTY_CONTEXT): return foldl_fn_(arr, f_like_to_func(f), zero, ctx)

func get_fld_(obj, field_name: String): return obj[field_name]

func get_fld_or_else_(obj, field_name: String, default):
	if obj == null || field_name == null: return default
	if obj is Dictionary:
		if !obj.has(field_name): return default
	else:
		if !field_name in obj: return default
	return obj[field_name]

func get_fld_or_null_(obj, field_name: String): return get_fld_or_else_(obj, field_name, null)

func size_(x):
	if x is Array: return x.size()
	if x is String: return x.length()
	crash_("size is allowed only for Array and String")

func sort_(arr: Array) -> Array:
	var res = arr.duplicate()
	res.sort()
	return res

func _sort_by_workaround(a, b, f: FuncRef): return f.call_func(a, b)

func sort_by_(arr: Array, f: FuncRef) -> Array:
	var res = arr.duplicate()
	var wrapped_f = CtxFRef2.new(funcref(self, "_sort_by_workaround"), f)
	res.sort_custom(wrapped_f, "call_func")
	return res

func _sort_by_fld_helper(a, b, field_name: String) -> bool: return a[field_name] < b[field_name]

func sort_by_fld_(arr: Array, field_name: String) -> Array:
	var sort_f = CtxFRef2.new(funcref(self, "_sort_by_fld_helper"), field_name)
	return sort_by_(arr, sort_f.ref)

func _cmp_snd(a: Array, b: Array) -> bool: return a[1] < b[1]

func sort_with_(arr: Array, map_f: FuncRef) -> Array:
	var with_vals = []
	for x in arr: with_vals.push_back([x, map_f.call_func(x)])
	var sorted = sort_by_(with_vals, funcref(self, "_cmp_snd"))
	var res = []
	for x in sorted: res.push_back(x[0])
	return res

func zip_(a: Array, b: Array) -> Array:
	var r = []
	for i in range(0, min(a.size(), b.size())): r.push_back([a[i], b[i]])
	return r

func fst_(pair: Array): return pair[0]

func snd_(pair: Array): return pair[1]

func eq_(a, b) -> bool: return a == b

func eqd_(a, b) -> bool:
	# TODO: better?
	return to_json(a) == to_json(b)

func compile_script_(src: String):
	var script = GDScript.new()
	script.set_source_code(src)
	script.reload()
	var obj = Reference.new()
	obj.set_script(script)
	return obj

var lambda_regex

func parse_fn(expr: String) -> Array:
	if lambda_regex == null:
		lambda_regex = RegEx.new()
		lambda_regex.compile("^((?:[a-zA-Z_]+(?:\\s*:\\s*)?(?:\\s*,\\s*)?)*)\\s*(->|=>)\\s*(.*)$")
	var found = lambda_regex.search(expr)
	if found == null: crash_("Failed to parse lambda expression: %s" % expr)
	return [found.get_string(1), found.get_string(2), found.get_string(3)]

func function_expr_to_script_(expr: String) -> String:
	var parsed = parse_fn(expr); var args = parsed[0]; var op = parsed[1]; var body = parsed[2] # how I miss destructuring...
	var retPart = "return " if op == "=>" else ""
	var src = "func f(%s):%s%s" % [args, retPart, body]
	return src

var _function_cache = {}

# context?
# body support? e.g. "x => { print(x); return x + 1 }"

func function_(expr: String) -> FuncRef:
	var scr
	if expr in _function_cache:
		scr = _function_cache[expr]
	else:
		var src = function_expr_to_script_(expr)
		scr = compile_script_(src)
		_function_cache[expr] = scr
	return funcref(scr, "f")

func sample_or_null_(arr: Array):
	if is_empty_(arr): return null
	return arr[randi() % arr.size()]

func sample_(arr: Array):
	assert_(arr.size() != 0, "Expecting non-empty array")
	return sample_or_null_(arr)

func flatten_(xs: Array) -> Array:
	var res:= []
	for ys in xs:
		assert_(ys is Array, "flatten: all items in an Array must be of type Array")
		res += ys
	return res

func take_(xs: Array, n: int) -> Array:
	var res:= []
	for i in range(0, min(xs.size(), n)): res.push_back(xs[i])
	return res

func take_right_(xs: Array, n: int) -> Array:
	var res:= []
	for i in range(max(0, xs.size() - n), xs.size()): res.push_back(xs[i])
	return res

func take_while_(xs: Array, p) -> Array:
	if is_empty_(xs): return []
	var res:= []
	var pf = f_like_to_func(p)
	var i:= 0
	while i < xs.size() && pf.call_func(xs[i]):
		res.push_back(xs[i])
		i += 1
	return res

func drop_(xs: Array, n: int) -> Array:
	var res:= []
	for i in range(clamp(n, 0, xs.size()), xs.size()): res.push_back(xs[i])
	return res

func drop_right_(xs: Array, n: int) -> Array:
	var res:= []
	for i in range(0, clamp(xs.size() - n, 0, xs.size())): res.push_back(xs[i])
	return res

func f_like_to_func(f):
	if f is FuncRef: return f
	elif f is CtxFRef1 || f is CtxFRef2 || f is FlowF: return f
	elif f is String: return function_(f)
	elif f is Array: return CtxFRef1.new(f_like_to_func(f[0]), f[1])
	crash_("Unexpected function-like input: %s" % f)

func reverse_(xs: Array) -> Array:
	var r = xs.duplicate()
	r.invert()
	return r

func pipe_(input, functions: Array, options = null):
	var r = input
	var debug_print = get_fld_or_else_(options, "print", false)
	var step = 0
	if debug_print: print("[GG] pipe: input = %s" % [input])
	for f in functions:
		r = f_like_to_func(f).call_func(r)
		step += 1
		if debug_print: print("[GG] pipe: step = %s, value = %s" % [step, r])
	return r

func flow_(functions: Array): return FlowF.new(map_(functions, funcref(self, "f_like_to_func")))

func is_empty_ctx(x) -> bool: return x is String and x == _EMPTY_CONTEXT

func call_f0_w_ctx(f, ctx = _EMPTY_CONTEXT): return f.call_func() if is_empty_ctx(ctx) else f.call_func(ctx)
func call_f1_w_ctx(f, x, ctx = _EMPTY_CONTEXT): return f.call_func(x) if is_empty_ctx(ctx) else f.call_func(x, ctx)
func call_f2_w_ctx(f, x, y, ctx = _EMPTY_CONTEXT):
	return f.call_func(x, y) if is_empty_ctx(ctx) else f.call_func(x, y, ctx)

func tap_(x, f):
	f_like_to_func(f).call_func(x)
	return x

func sum_(xs: Array) -> int:
	var r:= 0
	for x in xs: r += x
	return r

func product_(xs: Array) -> int:
	var r:= 1
	for x in xs: r *= x
	return r

func all_(xs: Array, p) -> bool:
	var r:= true
	p = f_like_to_func(p)
	for x in xs: r = r && p.call_func(x)
	return r

func any_(xs: Array, p) -> bool:
	var r:= false
	p = f_like_to_func(p)
	for x in xs: r = r || p.call_func(x)
	return r

func without_(xs: Array, y) -> Array:
	var r:= []
	for x in xs: if x != y: r.push_back(x)
	return r

func compact_(xs: Array) -> Array: return without_(xs, null)

func append_(xs: Array, y) -> Array:
	var r:= xs.duplicate()
	r.push_back(y)
	return r

func prepend_(xs: Array, y) -> Array:
	var r:= xs.duplicate()
	r.push_front(y)
	return r

func concat_(xs: Array, ys: Array) -> Array: return xs + ys

func concat_left_(xs: Array, ys: Array) -> Array: return ys + xs

func replicate_(x, n: int) -> Array:
	var r:= []
	for i in range(n): r.push_back(x)
	return r

func call_spread_(f: FuncRef, arr: Array):
	match arr.size():
		0: return f.call_func()
		1: return f.call_func(arr[0])
		2: return f.call_func(arr[0], arr[1])
		3: return f.call_func(arr[0], arr[1], arr[2])
		4: return f.call_func(arr[0], arr[1], arr[2], arr[3])
		5: return f.call_func(arr[0], arr[1], arr[2], arr[3], arr[4])
		6: return f.call_func(arr[0], arr[1], arr[2], arr[3], arr[4], arr[5])
		7: return f.call_func(arr[0], arr[1], arr[2], arr[3], arr[4], arr[5], arr[6])
		8: return f.call_func(arr[0], arr[1], arr[2], arr[3], arr[4], arr[5], arr[6], arr[7])
		9: return f.call_func(arr[0], arr[1], arr[2], arr[3], arr[4], arr[5], arr[6], arr[7], arr[8])
		10: return f.call_func(arr[0], arr[1], arr[2], arr[3], arr[4], arr[5], arr[6], arr[7], arr[8], arr[9])
		_: push_error("call_spreaded doesn't support this number of arguments")

func is_empty_(xs: Array) -> bool: return xs.size() == 0

func new_array_(x, dims: Array) -> Array:
	if is_empty_(dims): return []
	var cur_dim = last_(dims)
	var res = replicate_(x, cur_dim)
	if x && (x is Array || (x is Object && "duplicate" in x)): res = map_(res, "x => x.duplicate()")
	var last_dim = dims.size() == 1
	return res if last_dim else new_array_(res, init_(dims))

func generate_array_(f, dims: Array) -> Array:
	return _generate_array_(f_like_to_func(f), dims, [])

func _generate_array_(f, dims: Array, coords: Array) -> Array:
	if is_empty_(dims): return []
	var cur_dim = head_(dims)
	var last_dim = dims.size() == 1
	if last_dim: return map_(range(cur_dim), "i, ctx => ctx[0].call_func(ctx[1] + [i])", [f, coords])
	else:
		return map_(range(cur_dim), "i, ctx => ctx[0].call_func(ctx[1], ctx[2], [i] + ctx[3])", [funcref(self, "_generate_array_"), f, tail_(dims), coords])

func get_fields_(obj, field_names: Array) -> Array:
	var r:= []
	for f in field_names: r.push_back(obj[f])
	return r

func set_fields_(obj, values: Array, field_names: Array) -> void:
	for i in range(field_names.size()): obj[field_names[i]] = values[i]

func bool_(cond: bool, on_false, on_true): if cond: return on_true; else: return on_false

func bool_lazy_(cond: bool, on_false, on_true): return bool_(cond, f_like_to_func(on_false), f_like_to_func(on_true)).call_func()

func pause_one_(node: Node, value: bool) -> void:
	node.set_process(!value)
	node.set_physics_process(!value)
	node.set_process_input(!value)
	node.set_process_internal(!value)
	node.set_process_unhandled_input(!value)
	node.set_process_unhandled_key_input(!value)

func pause_(node: Node, value: bool) -> void:
	pause_one_(node, value)
	for ch in node.get_children():
		pause_(ch, value)

func const_(x): return CtxFRef1.new(function_("a, b => b"), x)

func group_with_(arr: Array, f) -> Array:
	var mapper = f_like_to_func(f)
	var r:= []
	var c:= []
	for x in arr:
		if is_empty_(c): c = [x]
		else:
			if mapper.call_func(c[0]) == mapper.call_func(x): c.push_back(x)
			else:
				r.push_back(c)
				c = [x]
	if !is_empty_(c): r.push_back(c)
	return r

func transpose_(arr: Array) -> Array:
	var rows = size_(arr)
	if rows == 0: return []
	var cols = size_(arr[0])
	if cols == 0: return []
	var res:= new_array_(null, [cols, rows])
	for x in range(cols):
		for y in range(rows):
			res[x][y] = arr[y][x]
	return res

func nub_(xs: Array) -> Array:
	var res:= []
	for x in xs:
		if is_empty_(res) || last_(res) != x: res.push_back(x)
	return res

func uniq_(xs: Array) -> Array:
	var res:= []
	for x in xs:
		if !res.has(x): res.push_back(x)
	return res

func float_arr_to_int_arr_(xs: Array) -> Array: return map_(xs, "x => int(x)")
