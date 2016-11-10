package test.result_generation;
import planner.pddl.tree.TreeNode;
import planner.pddl.Domain;
import planner.pddl.Problem;
import planner.pddl.tree.Tree;
import planner.pddl.tree.TreeNodeIntFunctionValue;

import planner.pddl.Planner;
import planner.pddl.planner.PlannerActionNode;
import planner.pddl.heuristic.Heuristic;

import planner.pddl.Utilities;

/**
 * ...
 * @author 
 */
class ResultGeneratorPartialRangeLargeDomain
{
	
	static var path:String = "../../src/test/result_generation/PartialRangeLargeDomain/";
	var domain_path:String = path + "SettlersIntegerParameters.pddl";
	var problem_path:String = path + "problem_file";
	var results_path:String = path + "results.txt";
	
	var repeats:Int = 5;
	
	/*var ratios:Array<Float> = [
		0.001, 0.01, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1
	];*/
	
	/*var domain_sizes:Array<Int> = [
		10, 25, 50, 100, 250, 500, 1000, 2500, 5000, 10000
	];*/
	
	
	public function new() 
	{
		
		
		
	}
	
	public function Run(domain_size_:Int, ratio_:Float):Bool
	{
		trace("domain: " + domain_size_ + " ratio: " + ratio_);		
		var domain:Domain = new Domain(domain_path);
		var problem:Problem = new Problem(problem_path, domain);
		
		// Set the goal to be equal to the parameter
		
		var goal_tree:Tree = problem.GetGoalTree();
		var changing_node:TreeNodeIntFunctionValue = cast(goal_tree.GetBaseNode().GetChildren()[0].GetChildren()[1], TreeNodeIntFunctionValue);
		Main.Assert(changing_node.GetParent().toString() == ">= (housing location0) (1) ", "Base problem file has changed: ResultGeneratorPartialRangeLargeDomain");
		
		changing_node.SetValue("" + domain_size_);
		
		
		// Set the range of actions to be the same as the goal node
		problem.SetInitialFunction("target", domain_size_);
		
		
		//print to show the change
		trace(problem.GetClonedInitialState().GetFunction("target"));
		
		
		
		// lets start the tests and output to the results file
		
		Utilities.WriteToFile(results_path, "Domain size: " + domain_size_ + " Ratio: " + ratio_ + "\n", true);
		var average_times:Float = 0;
		
		var array:Array<PlannerActionNode> = [];
		var planner:Planner = null;
		
		for (i in 0...repeats)
		{
			var start:Float = Sys.cpuTime();
			
			planner = new Planner();
			array = planner.FindPlan(domain, problem, new Heuristic(domain, problem), true, ratio_);
			
			average_times += Sys.cpuTime() - start;
		}
		
		Utilities.WriteToFile(results_path, " time = " + (average_times / repeats), true);
		Utilities.WriteToFile(results_path, "\n", true);
		
		Utilities.WriteToFile(results_path, "Plan length: " + array.length + "\n", true);
		Utilities.WriteToFile(results_path, "Closed list length: " + planner.GetClosedListLength() + " Open list length: " + planner.GetOpenListLength() + "\n", true);
		
		for (i in 0...array.length)
		{
			Utilities.WriteToFile(results_path, array[i].GetActionTransform() + "\n", true);
		}
		
		Utilities.WriteToFile(results_path, "\n\n\n", true);
		
		
		
		return true;
		
	}
	
}