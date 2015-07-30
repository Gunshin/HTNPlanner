package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class TreeNodeIntMinus extends TreeNodeInt
{

	public function new() 
	{
		super();
	}
	
	override public function Evaluate(parameters_:Map<String, Parameter>, state_:State, domain_:Domain):Bool
	{
		throw "This function should not be getting called.";
	}
	
	override public function Execute(parameters_:Map<String, Parameter>, state_:State, domain_:Domain):String
	{
		return Std.string(GetValueFromChild(0, parameters_, state_, domain_) - GetValueFromChild(1, parameters_, state_, domain_));
	}
}