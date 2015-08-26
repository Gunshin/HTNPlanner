package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class TreeNodeIntValue extends TreeNodeInt
{

	var value:String = null;
	
	public function new(value_:String) 
	{
		super(); //pass in a fresh array because we dont want any crazy cyclic shenanigans to happen
		
		value = value_;
	}
	
	override public function Evaluate(parameters_:Map<String, Parameter>, state_:State, domain_:Domain):Bool
	{
		throw "This function should not be getting called.";
	}
	
	override public function Execute(parameters_:Map<String, Parameter>, state_:State, domain_:Domain):String
	{
		return value;
	}
	
}