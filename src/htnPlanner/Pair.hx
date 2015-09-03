package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class Pair<U, V>
{
	// i would make this generic, but since i currently do not need anything other than a string pair, i will not complicate it
	// generics can occationally cause problems on certain languages
	public var a:U;
	public var b:V;

	public function new(a_:U, b_:V) 
	{
		a = a_;
		b = b_;
	}
	
	public function toString():String
	{
		return Std.string(a) + ":" + Std.string(b);
	}
	
}