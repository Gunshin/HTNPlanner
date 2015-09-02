package htnPlanner;
import htnPlanner.tree.Tree;

/**
 * ...
 * @author Michael Stephens
 */
class Action
{
	var name:String = null;
	
	var data:ActionData = new ActionData();
	
	var precondition:Tree = null;
	var effect:Tree = null;
	

	public function new(name_:String)
	{
		name = name_;
	}
	
	public function SetPreconditionTree(tree_:Tree)
	{
		precondition = tree_;
	}
	
	public function SetEffectTree(tree_:Tree)
	{
		effect = tree_;
	}
	
	public function GetName():String
	{
		return name;
	}
	
	public function Evaluate(state_:State, domain_:Domain):Bool
	{
		return precondition.Evaluate(data, state_, domain_);
	}
	
	public function Execute(state_:State, domain_:Domain):State
	{
		var cloned:State = state_.Clone();
		effect.Execute(data, cloned, domain_);
		return cloned;
	}
	
	public function toString():String
	{
		return name;
	}
	
	public function GetData():ActionData
	{
		return data;
	}
	
	public function GetEffectTree():Tree
	{
		return effect;
	}
	
	public function GetPreconditionTree():Tree
	{
		return precondition;
	}
	
}