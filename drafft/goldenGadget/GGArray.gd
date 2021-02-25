extends Resource

## A wrapper of an `Array` offering a rich selection of general utility functions.
##
## **Note**: Arrays (and other types) passed and returned are considered immutable. It is recommended to not mutate them.
## If you break this rule, it may lead to unexpected consequences.
##
## Type parameter `T` (`any`) is the type items in [[GGArray]].
## @typeParam T {any} Type of items in [[GGArray]]
## @fileDocumentation

class_name GGArray

## @internal
var GGI = GGInternal.new()

## Inner [[Array]]. Usually used to end [[GGArray]] chains.
## @type {Array<T>}
## @example `G([1, 2]).val` returns `[1, 2]`
var val setget , _get_val

## Get length of the wrapped array.
## @type {int}
## @example `G([1, 2]).size` returns `2`
var size setget , _get_size

## Is the wrapped array empty?
## @type {bool}
## @example `G([]).is_empty` returns `true`
## @example `G([1, 2]).is_empty` returns `false`
var is_empty setget , _get_is_empty

var _val: Array

func _init(array: Array = []) -> void:
	_val = array

func _get_val() -> Array: return _val

# wrap
func _w_(x: Array) -> GGArray:
	# get_script is workaround GDScript's limitations (class cannot reference itself o_0)
	return get_script().new(x)
var _w = funcref(self, "_w_")

# unwrap
func _uw_(x: GGArray) -> Array: return x.val
var _uw = funcref(self, "_uw_")

# ----------------------------------------------------------------------------------------------------------------------

## Map every value in an array using a given function.
## @typeParam U {any} Output [[GGArray]] item type
## @param f {Func<T, U>} Mapping function (`FuncRef` or `CtxFRef1`)
## @param ctx {any} Context for function
## @return {U}
## @example `G([1, 2]).map_fn(GG.inc_).val` returns `[2, 3]`
func map_fn(f, ctx = GGI._EMPTY_CONTEXT) -> GGArray: return _w_(GGI.map_fn_(_val, f, ctx))

## Similar to [[map_fn]], but also supports function-like type.
## @typeParam U {any} Output [[GGArray]] item type
## @param f {FuncLike<T, U>} Mapping function
## @param ctx {any} Context for function
## @return {U}
## @example `G([1, 2]).map("x => x + 1").val` returns `[2, 3]`
func map(f, ctx = GGI._EMPTY_CONTEXT) -> GGArray: return _w_(GGI.map_(_val, f, ctx))

## Map an outer method (method of one specific object, usually one from which call originates - `self`)
func map_out_mtd(obj: Object, method_name: String, ctx = GGI._EMPTY_CONTEXT) -> GGArray:
	return map_fn(funcref(obj, method_name), ctx)

## Map an inner method (a method on objects in [[GGArray]] item).
func map_in_mtd(inner_method_name: String, ctx = GGI._EMPTY_CONTEXT) -> GGArray:
	var r:= []
	for x in _val: r.push_back(GGI.call_f0_w_ctx(funcref(x, inner_method_name), ctx))
	return _w_(r)

# ----------------------------------------------------------------------------------------------------------------------

## Map a field in `Object` or `Dictionary`.
## @example `G([{name = "Spock"}, {name = "Scotty"}]).map_fld("name").val` returns `["Spock", "Scotty"]`
func map_fld(field_name: String) -> GGArray:
	var r:= []
	for x in _val:
		if x && field_name in x: r.push_back(x[field_name])
	return _w_(r)

# ----------------------------------------------------------------------------------------------------------------------

## Call a function for every value in an array.
## @example `G(["Firefly", "Daedalus"]).for_each("x -> print(x)")` prints `Firefly` and `Daedalus` on separate lines (two calls)
func for_each(f, ctx = GGI._EMPTY_CONTEXT) -> void: GGI.for_each_(_val, f, ctx)

# ----------------------------------------------------------------------------------------------------------------------

## Join an array of `String`s.
## @example `G(["Dog", "Cat", "Frog"]).join(", ")` returns `"Dog, Cat, Frog"`
## @example `G([1, 2, 3]).join(", ", "<", ">")` returns `"<1, 2, 3>"`
func join(delim: String = "", before: String = "", after: String = "") -> String:
	return GGI.join_(_val, delim, before, after)

## Similar as [[join]], but wraps a result in [[GGArray]].
func join_w(delim: String = "", before: String = "", after: String = "") -> GGArray:
	return _w_([join(delim, before, after)])

# ----------------------------------------------------------------------------------------------------------------------

func _get_size() -> int: return _val.size()

func _get_is_empty() -> bool: return self.size == 0

# ----------------------------------------------------------------------------------------------------------------------

## Filter out values from an array for which predicate function returns `false`.
func filter_fn(predicate, ctx = GGI._EMPTY_CONTEXT) -> GGArray: return _w_(GGI.filter_fn_(_val, predicate, ctx))

## Similar to [[filter_fn]], but supports [[FuncLike]].
## @example `G(range(-4, 4)).filter("x => x >= 2").val` returns `[2, 3]`
func filter(predicate, ctx = GGI._EMPTY_CONTEXT) -> GGArray: return _w_(GGI.filter_(_val, predicate, ctx))

## Filter contents using a method on one specific `Object`.
func filter_out_mtd(obj: Object, method_name: String, ctx = GGI._EMPTY_CONTEXT) -> GGArray:
	return filter_fn(funcref(obj, method_name), ctx)

## Filter contents using a method on each item in an array.
func filter_in_mtd(inner_method_name: String, ctx = GGI._EMPTY_CONTEXT) -> GGArray:
	var r:= []
	for x in _val:
		if GGI.call_f0_w_ctx(funcref(x, inner_method_name), ctx): r.push_back(x)
	return _w_(r)

# ----------------------------------------------------------------------------------------------------------------------

## Filter an array of objects using `bool` field.
## @example `G([{enabled = true, id = 0}, {enabled = false, id = 1}, {enabled = true, id = 2}]).filter_by_fld("enabled").map_fld("id").val` returns `[0, 2]`
func filter_by_fld(field_name: String) -> GGArray:
	var r:= []
	for x in _val:
		if field_name in x && x[field_name]: r.push_back(x)
	return _w_(r)

# ----------------------------------------------------------------------------------------------------------------------

## Filter an array of objects using one field and field value.
## @example `G([{id = 0, name = "Zero"}, {id = 1, name = "One"}]).filter_by_fld_val("id", 1).map_fld("name").val` returns `["One"]`
func filter_by_fld_val(field_name: String, field_value) -> GGArray:
	var r:= []
	for x in _val:
		if field_name in x && x[field_name] == field_value: r.push_back(x)
	return _w_(r)

# ----------------------------------------------------------------------------------------------------------------------

## Return a new [[GGArray]] omitting given value.
## @example `G([1, 2, 1]).without(1).val` returns `[2]`
func without(value_to_omit) -> GGArray: return _w_(GGI.without_(_val, value_to_omit))

## Return a new [[GGArray]] omitting `null` items.
## @example `G([1, null, 3]).compact().val` returns `[1, 3]`
func compact() -> GGArray: return _w_(GGI.compact_(_val))

# ----------------------------------------------------------------------------------------------------------------------

## Find a first element for which predicate holds. Crash on no match.
## @example `G([1, 2, 3], "x => x > 1")` returns `2`
## @example `G([1], "x => x > 1")` returns `null`
## @example `G([{id = 4, name = "Alice"}, {id = 7, name = "Bob"}]).find_or_null("x => x.name.length() == 3").id` returns `7`
func find_or_null(predicate, ctx = GGI._EMPTY_CONTEXT): return GGI.find_or_null_(_val, predicate, ctx)

## Find a first element for which predicate holds. Return `null` when no match is found.
func find(predicate, ctx = GGI._EMPTY_CONTEXT): return GGI.find_(_val, predicate, ctx)

# ----------------------------------------------------------------------------------------------------------------------

## Find an item by a value of a field.
## @example `G([{id = 0, name = "Zero"}, {id = 1, name = "One"}]).find_by_fld_val("id", 1).name` returns `"One"`
func find_by_fld_val(field_name: String, field_value):
	return filter_by_fld_val(field_name, field_value).head()

# ----------------------------------------------------------------------------------------------------------------------

## Find item in array for which precate holds and return its index.
## @param predicate {Func<T, bool>}
## @param ctx {any}
## @return {int | null}
func find_index_or_null(predicate, ctx = GGI._EMPTY_CONTEXT): return GGI.find_index_or_null_(_val, predicate, ctx)

## Find item in array for which precate holds and return its index. Crash when valid item isn't found.
## @param predicate {Func<T, bool>}
## @param ctx {any}
## @return {int}
func find_index(predicate, ctx = GGI._EMPTY_CONTEXT): return GGI.find_index_(_val, predicate, ctx)

# ----------------------------------------------------------------------------------------------------------------------

## Takes an operator and a zero (initial) value, reduces array to one value by repeatedly applying the operator to items from an array.
## @param f {Func<R, T, R>} Operator
## @return {R}
func foldl_fn(f: FuncRef, zero, ctx = GGI._EMPTY_CONTEXT): return GGI.foldl_fn_(_val, f, zero, ctx)

## Similar to [[foldl_fn]], but also supports [[FuncLike]].
## @example `G([1, 2, 3]).foldl("a, x => a + x", -6)` returns `0` (-6 + 1 + 2 + 3)
func foldl(f, zero, ctx = GGI._EMPTY_CONTEXT): return GGI.foldl_(_val, f, zero, ctx)

## Same as [[foldl_fn]], but instead of a `FuncRef` takes an object and a name of its method.
func foldl_mtd(obj: Object, method_name: String, zero, ctx = GGI._EMPTY_CONTEXT):
	return foldl_fn(funcref(obj, method_name), zero, ctx)

# ----------------------------------------------------------------------------------------------------------------------

## Calls [[FuncLike]] on the inner value.
func to(f): return GGI.f_like_to_func(f).call_func(_val)

## Calls [[FuncLike]] on the inner value and wraps the result in [[GGArray]].
func to_w(f) -> GGArray: return _w_(to(f))

# TODO: raw version passing self?

# ----------------------------------------------------------------------------------------------------------------------

## Get first item or crash on empty array.
## @example `G([1, 2, 3]).head()` returns `1`
func head(): return GGI.head_(_val)

## Get first item or `null` for empty array.
## @example `G([1, 2, 3]).head_or_null()` returns `1`
func head_or_null(): return GGI.head_or_null_(_val)

## Get last item or crash on empty array.
## @example `G([1, 2, 3]).last()` returns `3`
func last(): return GGI.last_(_val)

## Get last item or `null` for empty array.
## @example `G([1, 2, 3]).last()` returns `3`
func last_or_null(): return GGI.last_or_null_(_val)

## Get all items except first one.
## @example `G([1, 2, 3]).tail().val` returns `[2, 3]`
func tail() -> GGArray:
	GGI.assert_(_get_size() > 0, "cannot call tail on empty array")
	return _w_(GGI.tail_(_val))

## Get all items except last one.
## @example `G([1, 2, 3]).init().val` returns `[1, 2]`
func init() -> GGArray:
	GGI.assert_(_get_size() > 0, "cannot call init on empty array")
	return _w_(GGI.init_(_val))

# ----------------------------------------------------------------------------------------------------------------------

## Return a sorted [[GGArray]].
func sort() -> GGArray: return _w_(GGI.sort_(_val))

# lambda string support?

## Sort an array using a supplied compare function.
func sort_by(cmp_f: FuncRef) -> GGArray: return _w_(GGI.sort_by_(_val, cmp_f))

## Sort an array of objects by one given field.
func sort_by_fld(field_name: String) -> GGArray: return _w_(GGI.sort_by_fld_(_val, field_name))

## Sort an array using a mapping function (result is sorted on values obtained from the mapping function).
func sort_with(map_f: FuncRef) -> GGArray: return _w_(GGI.sort_with_(_val, map_f))

# ----------------------------------------------------------------------------------------------------------------------

## Zip together two arrays.
## A length of a result is same length as a length of a shorter array (meaning arrays are **not** padded with `null`s to be of same length, but the larger array is truncated to match the length of the shorter one).
## @example `G([1, 2]).zip(["a", "b"]).val` returns `[[1, "a"], [2, "b"]]`
## @example `G([1]).zip(["a", "b"]).val` returns `[[1, "a"]]`
func zip(other: Array) -> GGArray: return _w_(GGI.zip_(_val, other))

# ----------------------------------------------------------------------------------------------------------------------

## Does nothing, used to end a chain. Usually it's better to rather use chain-ending methods like [[for_each]] or [[to]].
## Can be used to suppress `The function 'map_out_mtd()' returns a value, but this value is never used.` and similar.
func noop() -> void: pass

# ----------------------------------------------------------------------------------------------------------------------

## Get a random item (crashes on an empty array).
## @example `G([1]).sample()` returns `1`
## @example `G(["Frog", "Toad"]).sample()` returns `"Frog"` or `"Toad"` with an equal chance
## @example `G([]).sample()` crashes
func sample(): return GGI.sample_(_val)

## Get a random item (`null` on an empty array).
## @example `G([1]).sample_or_null()` returns `1`
## @example `G(["Frog", "Toad"]).sample_or_null()` returns `"Frog"` or `"Toad"` with an equal chance
## @example `G([]).sample_or_null()` returns `null`
func sample_or_null(): return GGI.sample_or_null_(_val)

# ----------------------------------------------------------------------------------------------------------------------

## Flattens [[GGArray]] of `Array`s to [[GGArray]] (spreads items).
## @example `G([[1, 2], [3]]).flatten_raw().val` returns `[1, 2, 3]`
func flatten_raw() -> GGArray: return _w_(GGI.flatten_(_val))

## Flattens [[GGArray]] of [[GGArray|GGArrays]] to [[GGArray]] (spreads items).
## @example `G([G([1, 2]), G([3])]).flatten().val` returns `[1, 2, 3]`
func flatten() -> GGArray: return map_fld("val").flatten_raw()

# ----------------------------------------------------------------------------------------------------------------------

## Take `n` items from a start of an array.
## @example `G([1, 2, 3, 4, 5]).take(2).val` returns `[1, 2]`
func take(n: int) -> GGArray: return _w_(GGI.take_(_val, n))

## Take `n` items from an end of an array.
## @example `G([1, 2, 3, 4, 5]).take_right(2).val` returns `[4, 5]`
func take_right(n: int) -> GGArray: return _w_(GGI.take_right_(_val, n))

## Keep taking items from an array (from start) until predicate stops holding.
## @param p {FuncLike<T, bool>} Predicate
func take_while(p) -> GGArray: return _w_(GGI.take_while_(_val, p))

## Drop (skip) n items from a start of an array.
## @example `G([1, 2, 3, 4, 5]).drop(2).val` returns `[3, 4, 5]`
func drop(n: int) -> GGArray: return _w_(GGI.drop_(_val, n))

## Drop (skip) n items from an end of an array.
## @example `G([1, 2, 3, 4, 5]).drop_right(2).val` returns `[1, 2, 3]`
func drop_right(n: int) -> GGArray: return _w_(GGI.drop_right_(_val, n))

# ----------------------------------------------------------------------------------------------------------------------

## Reverse order of items in an array.
## @example `G([1, 2, 3]).reverse().val` returns `[3, 2, 1]`
func reverse() -> GGArray: return _w_(GGI.reverse_(_val))

# ----------------------------------------------------------------------------------------------------------------------

## Call FuncLike with inner value, ignore call result, return same array.
## @param f {FuncLike<T, any>}
## @return {GGArray<T>}
func tap(f) -> GGArray: # custom implementation to avoid rewrapping from using GGI.tap_
	GGI.f_like_to_func(f).call_func(_val)
	return self

# ----------------------------------------------------------------------------------------------------------------------

## Sum all items in an array.
## @example `G([2, 3, 5]).sum()` returns `10`
func sum() -> int: return GGI.sum_(_val)

## Multiply all items in an array.
## @example `G([2, 3, 5]).product()` returns `30`
func product() -> int: return GGI.product_(_val)

## Does a predicate hold for all items?
## @param p {FuncLike<T, bool>}
## @return {bool}
## @example `G([]).all("x => x > 0")` returns `true`
## @example `G([1, 2, 1]).all("x => x > 0")` returns `true`
## @example `G([1, 0, 1]).all("x => x > 0")` returns `false`
func all(p) -> bool: return GGI.all_(_val, p)

## Does a predicate hold for any item?
## @param p {FuncLike<T, bool>}
## @return {bool}
## @example `G([]).any("x => x == 2")` returns `false`
## @example `G([1, 2, 1]).any("x => x == 2")` returns `true`
## @example `G([1, -1, 1]).any("x => x == 2")` returns `false`
func any(p) -> bool: return GGI.any_(_val, p)

## Append an item to an end of the array.
func append(y) -> GGArray: return _w_(GGI.append_(_val, y))

## Prepend an item to a start of the array.
func prepend(y) -> GGArray: return _w_(GGI.prepend_(_val, y))

## Concatenate arrays (`other` to end).
func concat(other: Array) -> GGArray: return _w_(GGI.concat_(_val, other))

## Concatenate arrays (`other` to start)
func concat_left(other: Array) -> GGArray: return _w_(GGI.concat_left_(_val, other))

## Go through an array in order and group together sequences of items for which `f` returns same value.
## @typeParam U {any} Type of values for comparison (usually a type of field of `Object`/`Dictionary`)
## @param f {FuncLike<T, U>} Mapping function used on all items and retuned values are used for comparisons
## @return {GGArray<GGArray<T>>} Grouped items
## @example `G([{name = "Walt", rank = 0}, {name = "Muffy", rank = 0}, {name = "Yen", rank = 1}]).group_with("x => x.rank")` returns `GGArray`s equivalent to `[[{name = "Walt", rank = 0}, {name = "Muffy", rank = 0}], [{name = "Yen", rank = 1}]]`
func group_with(f) -> GGArray: return _w_(GGI.group_with_(_val, f)).map(_w)

## Transpose a 2D matrix.
## @example `G([[1, 2], [3, 4]]).transpose()` returns `GGArray`s equivalent to `[[1, 3], [2, 4]]`
func transpose() -> GGArray: return _w_(GGI.transpose_(_val)).map(_w)

## Wrap inner `Array`s with `GGArray`.
func wrap() -> GGArray: return map(_w)

## Unwrap inner `GGArray`s to `Array`s.
func unwrap() -> GGArray: return map(_uw)

## Cut all sequences of same values to be of length one.
func nub() -> GGArray: return _w_(GGI.nub_(_val))

## Remove all duplicate items.
func uniq() -> GGArray: return _w_(GGI.uniq_(_val))

## Convert array of floats to array of integers. Useful for correcting parsed JSONs.
func float_arr_to_int_arr() -> GGArray: return _w_(GGI.float_arr_to_int_arr_(_val))

# TODO:
# intersperse
# ? group_all_with
# ? reject/filter_not
