package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class TreeNodePredicate extends TreeNode
{
	
	var predicate:Predicate = null;
	var paramNames:Array<String> = null;

	public function new(predicate_:Predicate, paramNames_:Array<String>) 
	{
		super();
		
		predicate = predicate_;
		paramNames = paramNames_;
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