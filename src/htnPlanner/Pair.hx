package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class Pair
{
	// i would make this generic, but since i currently do not need anything other than a string pair, i will not complicate it
	// generics can occationally cause problems on certain languages
	public var a:String;
	public var b:String;

	public function new(a_:String, b_:String) 
	{
		a = a_;
		b = b_;
	}
	
	public function toString():String
	{
		return a + ":" + b;
	}
	
}