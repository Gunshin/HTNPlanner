package htnPlanner.tree;
import htnPlanner.tree.TreeNode;

/**
 * ...
 * @author 
 */
class TreeNodeValue extends TreeNode
{
	
	var valueName:String = null;
	
	public function new(valueName_:String) 
	{
		super();
		
		valueName = valueName_;
	}
	
	override public function Evaluate(data_:ActionData, state_:State, domain_:Domain):Bool
	{
		throw "This function should not be getting called.";
	}
	
	override public function Execute(data_:ActionData, state_:State, domain_:Domain):String
	{
		return data_.GetValue(valueName).GetValue();
	}
	
	override public function GetRawName():String
	{
		return valueName;
	}
	
	override public function GetRawTreeString():String
	{
		return valueName;
	}
	
}