package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class TreeNodeIntIncrease extends TreeNodeInt
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
		var functionOneID:String = children[0].Execute(parameters_, state_, domain_);
		
		var functionOneValue:Int = state_.GetFunction(functionOneID);
		
		state_.SetFunction(functionOneID, functionOneValue + GetValueFromChild(1, parameters_, state_, domain_));
		
		return null;
	}
}