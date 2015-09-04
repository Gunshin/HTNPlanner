package planner.pddl.tree;
import planner.pddl.ActionData;
import planner.pddl.Domain;
import planner.pddl.State;

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
	
	override public function Evaluate(data_:ActionData, state_:State, domain_:Domain):Bool
	{
		for (i in children)
		{
			if (!i.Evaluate(data_, state_, domain_))
			{
				return false;
			}
		}
		return true;
	}
	
	override public function Execute(data_:ActionData, state_:State, domain_:Domain):String
	{
		for (i in children)
		{
			// incase the child is a predicate. predicates do not affect the state on their own.
			var value_:String = i.Execute(data_, state_, domain_);
			
			if (value_ != null)
			{
				state_.AddRelation(value_);
			}
		}
		
		return null;
	}
	
	/*override public function GenerateRangeOfValues(data_:ActionData, state_:State, domain_:Domain):Array<String>
	{
		for (i in children)
		{
			switch(i.GetRawName())
			{
				case "==":
					
				
			}
		}
	}*/
	
	override public function GetRawName():String
	{
		return "and";
	}
}