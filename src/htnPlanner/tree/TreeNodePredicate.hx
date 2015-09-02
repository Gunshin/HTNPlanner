package htnPlanner.tree;
import htnPlanner.tree.TreeNode;

/**
 * ...
 * @author Michael Stephens
 */
class TreeNodePredicate extends TreeNode
{
	
	var predicate:Predicate = null;
	var paramNames:Array<String> = new Array<String>();

	public function new(predicate_:Predicate, params_:Array<RawTreeNode>) 
	{
		super();
		
		predicate = predicate_;
		
		for (param in params_)
		{
			paramNames.push(param.value);
		}
	}
	
	override public function Evaluate(data_:ActionData, state_:State, domain_:Domain):Bool
	{
		var predicateValue:String = predicate.Construct(data_, paramNames);
		return state_.Exists(predicateValue);
	}
	
	override public function Execute(data_:ActionData, state_:State, domain_:Domain):String
	{
		return predicate.Construct(data_, paramNames);
	}
}