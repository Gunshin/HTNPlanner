package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class TreeNodePredicate extends TreeNode
{
	
	var predicate:Predicate = null;

	public function new(predicate_:Predicate) 
	{
		super();
		
		predicate = predicate_;
	}
	
	override public function Execute(parameters_:Map<String, Parameter>, state_:State, domain_:Domain):Bool
	{
		var predicateValue:String = predicate.Construct(parameters_);
		return state_.Exists(predicateValue);
	}
}