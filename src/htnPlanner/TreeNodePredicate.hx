package htnPlanner;

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
	
	override public function Evaluate(parameters_:Map<String, Parameter>, state_:State, domain_:Domain):Bool
	{
		var predicateValue:String = predicate.Construct(parameters_, paramNames);
		return state_.Exists(predicateValue);
	}
	
	override public function Execute(parameters_:Map<String, Parameter>, state_:State, domain_:Domain):String
	{
		return predicate.Construct(parameters_, paramNames);
	}
}