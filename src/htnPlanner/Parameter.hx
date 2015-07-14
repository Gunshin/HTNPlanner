package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class Parameter
{
	public var name:String = null;
	public var type:String = null;
	public var value:String = null;

	public function new(name_:String, type_:String, value_:String) 
	{
		name = name_;
		type = type_;
		value = value_;
	}
	
}