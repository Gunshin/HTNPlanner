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
		//Utilities.Log("TreeNodeInt.Evaluate: " + GetRawTreeString() + " _ " + GetValueFromChild(0, data_, state_, domain_) + " _ " + GetValueFromChild(1, data_, state_, domain_));
		var val_a:Null<Int> = GetValueFromChild(0, data_, state_, domain_);
		var val_b:Null<Int> = GetValueFromChild(1, data_, state_, domain_);
		
		return val_a != null && val_b != null && ComparisonEvaluate(val_a, val_b);
	}
	
	public function GetValueFromChild(childIndex_:Int, data_:ActionData, state_:State, domain_:Domain):Null<Int>
	{
		var childOneExecute:String = children[childIndex_].Execute(data_, state_, domain_);
		
		var value:Null<Int> = Std.parseInt(childOneExecute); // if it is an int, great! it might be a function though
		//trace(childIndex_ + " _ " + children + " ____ " + childOneExecute);
		if (value == null && childOneExecute != null)
		{
			/*if (childOneExecute.charAt(0) == "~")
			{
				trace(Std.parseInt(data_.GetValue(childOneExecute).GetValue()));
				value = Std.parseInt(data_.GetValue(childOneExecute).GetValue());
			}
			else
			{*/
				value = state_.GetFunction(childOneExecute);
			//}
			
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
		
		// have to account for:
		// a function name
		// a raw integer value
		// ?? - dont remember the last one
		
		var split:Array<String> = childOneExecute.split(Pair.seperator);
		
		//Utilities.Log("HeuristicGetValueFromChild: " + childIndex_ + " _ " + childOneExecute + " _ " + split + " _ " + split.length + "\n");
		
		if (split[0] == childOneExecute)
		{
			// this value may just be a standard number, so set both max and min to it
			var num:Null<Int> = Std.parseInt(split[0]);
			
			if (num != null)
			{
				//Utilities.Log("TreeNodeInt.HeuristicGetValueFromChild: a\n");
				bounds = new Pair(num, num);
			}
			else
			{
				bounds = state_.GetFunctionBounds(childOneExecute);
				//Utilities.Log("TreeNodeInt.HeuristicGetValueFromChild: b\n");
			}
		}
		else
		{
			bounds = new Pair(Std.parseInt(split[0]), Std.parseInt(split[1]));
			//Utilities.Log("TreeNodeInt.HeuristicGetValueFromChild: c " + GetRawName() + " _ " + bounds + "\n");
		}
		//Utilities.Log("TreeNodeInt.HeuristicGetValueFromChild: " + GetRawTreeString() + " === " + childOneExecute + " ___ " + bounds +"\n");
		return bounds;
	}
	
	/**
	 * 
	 * Returns a list of function names and which child they are located on in this node
	 * 
	 * @param	action_data_
	 * @return
	 */
	public function GetFunctionNames(action_data_:ActionData):Array<Pair<String, Int>>
	{
		
		var returnee:Array<Pair<String, Int>> = new Array<Pair<String, Int>>();
		
		for (child_index in 0...children.length)
		{
			var child:TreeNode = children[child_index];
			Tree.Recursive(child, function(node_) {
				if (Std.is(node_, TreeNodeFunction))
				{
					var func:TreeNodeFunction = cast(node_, TreeNodeFunction);
					returnee.push(new Pair(func.Construct(action_data_), child_index));
				}
				
				return true;
			});
		
		}
		
		return returnee;
	}
	
	public function ComparisonEvaluate(valueA_:Int, valueB_:Int):Bool { throw "must override this function"; }	
	
	public function HeuristicComparisonEvaluate(valueA_:Pair<Int, Int>, valueB_:Pair<Int, Int>):Bool { throw "must override this function"; }
	
	public function GetHeuristicBounds(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):Pair<Int, Int> { throw "must override this function"; }
	
	override public function Execute(data_:ActionData, state_:State, domain_:Domain):String { throw "must override this function"; }
	
	override public function HeuristicExecute(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):String { throw "must override this function"; }
	
}