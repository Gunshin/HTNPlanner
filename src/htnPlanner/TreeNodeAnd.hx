package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class TreeNodeAnd extends TreeNode
{

	public function new() 
	{
		super();
	}
	
	override public function Evaluate(parameters_:Map<String, Parameter>, state_:State, domain_:Domain):Bool
	{
		for (i in children)
		{
			if (!i.Evaluate(parameters_, state_, domain_))
			{
				return false;
			}
		}
		return true;
	}
	
	override public function Execute(parameters_:Map<String, Parameter>, state_:State, domain_:Domain):String
	{
		for (i in children)
		{
			// incase the child is a predicate. predicates do not affect the state on their own.
			var value_:String = i.Execute(parameters_, state_, domain_);
			
			if (value_ != null)
			{
				state_.AddRelation(value_);
			}
		}
		
		return null;
	}
	
	
}