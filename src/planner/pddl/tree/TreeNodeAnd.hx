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
	
	override public function GenerateRangeOfValues(valueName_:String, state_:State, domain_:Domain):Array<String>
	{
		var returnee:Array<String> = new Array<String>();
		var max:Null<Int> = null;
		var min:Null<Int> = null;
		
		for (child in children)
		{
			
			var firstChildHasTargetValue:Bool = false;
			Tree.Recursive(function(node_)
			{
				if (Utilities.Compare(node_.GetRawName(), valueName_) == 0)
				{
					firstChildHasTargetValue = true;
					return false; // stop recursion
				}
				
				return true; //continue recursion
			}, child.children[0]);
			
			var nodeInt:TreeNodeInt = cast(child, TreeNodeInt);
			var indexToGetValue:Int = !firstChildHasTargetValue ? 0 : 1;
			var value:Int = nodeInt.GetValueFromChild(indexToGetValue, null, state_, domain_);
			
			var isMin:Bool = false;
			switch(child.GetRawName())
			{
				case "==":
					throw "Not implemented yet";
				case ">":
					isMin = firstChildHasTargetValue;
					value += 1;
				case ">=":
					isMin = firstChildHasTargetValue;
				case "<":
					isMin = !firstChildHasTargetValue;
				case "<=":
					isMin = !firstChildHasTargetValue;
					value += 1;
			}
			
			if (isMin && (min == null || value < min))
			{
				min = value;
			}
			else if(!isMin && (max == null || value > max))
			{
				max = value;
			}
		}
		
		if (min == null)
		{
			throw "Min is null";
		}
		else if (max == null)
		{
			throw "Max is null";
		}
		
		for (num in min...max)
		{
			returnee.push(Std.string(num));
		}
		
		return returnee;
	}
	
	override public function GetRawName():String
	{
		return "and";
	}
}