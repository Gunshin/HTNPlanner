package htnPlanner.tree;
import htnPlanner.tree.TreeNodeInt;

/**
 * ...
 * @author Michael Stephens
 */
class TreeNodeIntMultiply extends TreeNodeInt
{

	public function new() 
	{
		super();
	}
	
	override public function Evaluate(data_:ActionData, state_:State, domain_:Domain):Bool
	{
		throw "This function should not be getting called.";
	}
	
	override public function Execute(data_:ActionData, state_:State, domain_:Domain):String
	{
		return Std.string(GetValueFromChild(0, data_, state_, domain_) * GetValueFromChild(1, data_, state_, domain_));
	}
}