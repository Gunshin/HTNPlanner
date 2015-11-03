package planner.pddl.tree;
import planner.pddl.ActionData;
import planner.pddl.Domain;
import planner.pddl.heuristic.HeuristicData;
import planner.pddl.Pair;
import planner.pddl.State;
import planner.pddl.tree.TreeNode;

/**
 * ...
 * @author Michael Stephens
 */
class TreeNodeInt extends TreeNode
{

	public function new() 
	{
		super();
	}
	
	override public function Evaluate(data_:ActionData, state_:State, domain_:Domain):Bool
	{
		return ComparisonEvaluate(GetValueFromChild(0, data_, state_, domain_), GetValueFromChild(1, data_, state_, domain_));
	}
	
	public function GetValueFromChild(childIndex_:Int, data_:ActionData, state_:State, domain_:Domain):Int
	{
		var childOneExecute:String = children[childIndex_].Execute(data_, state_, domain_);
		
		var value:Null<Int> = Std.parseInt(childOneExecute); // if it is an int, great! it might be a function though
		if (value == null)
		{
			value = state_.GetFunction(childOneExecute);
		}
		
		return value;
	}
	
	override public function HeuristicEvaluate(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):Bool 
	{
		return HeuristicComparisonEvaluate(HeuristicGetValueFromChild(0, data_, heuristic_data_, state_, domain_), HeuristicGetValueFromChild(1, data_, heuristic_data_, state_, domain_));
	}
	
	public function HeuristicGetValueFromChild(childIndex_:Int, data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):Pair<Int, Int>
	{
		var childOneExecute:String = children[childIndex_].HeuristicExecute(data_, heuristic_data_, state_, domain_);
		
		var bounds:Pair<Int, Int> = null;
		
		var split:Array<String> = childOneExecute.split(Pair.seperator);
		if (split[0] == childOneExecute)
		{
			// this value may just be a standard number, so set both max and min to it
			var num:Null<Int> = Std.parseInt(split[0]);
			
			if (num != null)
			{
				bounds = new Pair(num, num);
			}
			else
			{
				bounds = state_.GetFunctionBounds(childOneExecute);
			}
		}
		else
		{
			bounds = new Pair(Std.parseInt(split[0]), Std.parseInt(split[1]));
		}
		
		
		return bounds;
	}
	
	public function GetFunctionNames():Array<String>
	{
		
		var returnee:Array<String> = new Array<String>();
		
		Tree.Recursive(this, function(node_) {
			if (node_.GetRawName().charAt(0) == "?")
			{
				returnee.push(node_.GetRawName());
			}
			
			return true;
		});
		
		return returnee;
	}
	
	public function ComparisonEvaluate(valueA_:Int, valueB_:Int):Bool { throw "must override this function"; }	
	
	public function HeuristicComparisonEvaluate(valueA_:Pair<Int, Int>, valueB_:Pair<Int, Int>):Bool { throw "must override this function"; }
	
	public function GetHeuristicBounds(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):Pair<Int, Int> { throw "must override this function"; }
	
	override public function Execute(data_:ActionData, state_:State, domain_:Domain):String { throw "must override this function"; }
	
	override public function HeuristicExecute(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):String { throw "must override this function"; }
	
}