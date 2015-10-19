package planner.pddl.tree;
import planner.pddl.ActionData;
import planner.pddl.Domain;
import planner.pddl.heuristic.HeuristicData;
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
	
	override public function HeuristicEvaluate(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):Bool 
	{
		for (i in children)
		{
			if (!i.HeuristicEvaluate(data_, heuristic_data_, state_, domain_))
			{
				return false;
			}
		}
		return true;
	}
	
	override public function HeuristicExecute(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):String 
	{
		for (i in children)
		{
			// incase the child is a predicate. predicates do not affect the state on their own.
			var value_:String = i.HeuristicExecute(data_, heuristic_data_, state_, domain_);
			
			if (value_ != null)
			{
				heuristic_data_.predicates.set(value_, true);
			}
		}
		
		return null;
	}
	
	override public function GenerateRangeOfValues(data_:ActionData, valueName_:String, state_:State, domain_:Domain):Array<String>
	{
		var returnee:Array<String> = new Array<String>();
		var max:Null<Int> = null;
		var min:Null<Int> = null;
		
		var has_value_range:Bool = false;
		
		for (child in children)
		{
			if(Utilities.Compare(child.GetRawName(), "and") == 0 || Utilities.Compare(child.GetRawName(), "or") == 0)
			{
				returnee = returnee.concat(child.GenerateRangeOfValues(data_, valueName_, state_, domain_));
			}
			else
			{
				// we do this so that we do not attempt to grab from statements that contain multiple values
				// eg. (< (~count) (~arc))
				var value_count:Int = 0;
				var contains_target_value:Bool = false;
				Tree.Recursive(child, function(node_)
				{
					if (Utilities.Compare(node_.GetRawName().charAt(0), "~") == 0)
					{
						value_count++;
					}
					if (Utilities.Compare(node_.GetRawName(), valueName_) == 0)
					{
						contains_target_value = true;
					}
					return true; //search through the hole structure
				});
				
				// we can only gain a set of values from a statement that contains one value
				if (value_count == 1 && contains_target_value)
				{
					has_value_range = true;
					
					// look and see if the left side of the statemen contains the target value
					var firstChildHasTargetValue:Bool = false;
					Tree.Recursive(child.children[0], function(node_)
					{
						if (Utilities.Compare(node_.GetRawName(), valueName_) == 0)
						{
							firstChildHasTargetValue = true;
							return false; // stop recursion
						}
						
						return true; //continue recursion
					});
					
					var nodeInt:TreeNodeInt = cast(child, TreeNodeInt);
					var indexToGetValue:Int = !firstChildHasTargetValue ? 0 : 1;
					var value:Int = nodeInt.GetValueFromChild(indexToGetValue, data_, state_, domain_);
					
					var isMin:Bool = false;
					switch(child.GetRawName())
					{
						case "==":
							throw "Dont add '==' statements for value ranges to 'and'. Only add to 'or'";
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
			}
		}
		
		if (has_value_range)
		{
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
		}
		
		return returnee;
	}
	
	override public function GenerateConcrete(action_data_:ActionData, state_:State, domain_:Domain):Array<TreeNode>
	{
		var concrete_and:TreeNodeAnd = new TreeNodeAnd();
		
		for (child in children)
		{
			for (conc in child.GenerateConcrete(action_data_, state_, domain_))
			{
				concrete_and.AddChild(conc);
			}
		}
		
		return [concrete_and];
	}
	
	override public function GetRawName():String
	{
		return "and";
	}
}