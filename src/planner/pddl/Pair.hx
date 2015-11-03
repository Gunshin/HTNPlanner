package planner.pddl;

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
	
	public function ToPlainString():String
	{
		return Std.string(a) + seperator + Std.string(b);
	}
	
	public function toString():String
	{
		return "{\"a\":\"" + Std.string(a) + "\", \"b\":\"" + Std.string(b) + "\"}";
	}
	
	public function Clone():Pair<U, V>
	{
		return new Pair(a, b);
	}
	
	/**
	 * This is used with the toString method to note a separation in values
	 */
	static public var seperator:String = ":";
}