package test;

import haxe.Timer;
import htnPlanner.Action;

import htnPlanner.Domain;
import htnPlanner.Problem;
import htnPlanner.Planner;
import htnPlanner.PlannerActionNode;

import htnPlanner.Utilities;
import htnPlanner.tree.TreeNodeFunction;
import htnPlanner.tree.TreeNodeInt;
import htnPlanner.tree.TreeNodeValue;

/**
 * ...
 * @author Michael Stephens
 */
class Main 
{
	
	//var domainLocation:String = "pddlexamples/IPC3/Tests2/Rovers/Numeric/NumRover.pddl";
	//var problemLocation:String = "pddlexamples/IPC3/Tests2/Rovers/Numeric/pfile1";
	var domainLocation:String = "pddlexamples/runescape/domain.pddl";
	var problemLocation:String = "pddlexamples/runescape/p1.pddl";
	
	public function new()
	{
		//UnitTests();
		
		var domain = new Domain(domainLocation);
		var problem = new Problem(problemLocation, domain);
		
		
		var prec:Array<String> = new Array<String>();
		domain.GetAction("Cut_Down_Tree").GetPreconditionTree().Recurse(function(node) {
			if (Std.is(node, TreeNodeValue))
			{
				var treeNode:TreeNodeValue = cast(node, TreeNodeValue);
				var parent:TreeNodeInt = cast(treeNode.GetParent(), TreeNodeInt);
				trace(Type.getClassName(Type.getClass(parent)));
				var p:Dynamic = cast(parent, Type.getClass(parent));
				//var p:String = parent.
				
			}
		});
		
		trace(prec);
		
		//domain.GetAction("Cut_Down_Tree").GetData().GetValue("~count").SetLowerBound(1);
		//domain.GetAction("Cut_Down_Tree").GetData().GetValue("~count").SetUpperBound(28);
		
		/*var start = Timer.stamp();
		
		var planner:Planner = new Planner();
		var array:Array<PlannerActionNode> = planner.FindPlan(domain, problem);
		
		trace(Timer.stamp() - start);
		
		trace("length: " + array.length);
		
		for (i in 0...array.length)
		{
			trace(array[i].GetActionTransform());
		}*/
		
	}
	
	public function UnitTests()
	{
		var domain:Domain = new Domain("src/test/runescape/domain.pddl");
		var problem = new Problem("src/test/runescape/p1.pddl", domain);
		
		trace("Starting Action Tests");
		var action:Action = domain.GetAction("Cut_Down_Tree");
		
		Assert((action != null), "Could not find action");
		Assert((action.GetData().GetParameterMap().exists("?resource")), "Could not find parameter");
		Assert((action.GetData().GetValue("~count") != null), "Could not find value");
		
		trace("Starting Plan Test");		
		var planner:Planner = new Planner();
		var array:Array<PlannerActionNode> = planner.FindPlan(domain, problem);
		
		Assert((array.length == 2), "Plan length is wrong");
		var compareArray:Array<String> = [
			"Move_To bank_area logs_area",
			"Cut_Down_Tree logs logs_area 15"
		];
		
		for (i in 0...array.length)
		{
			Assert((Utilities.Compare(array[i].GetActionTransform(), compareArray[i]) == 0), "Task: " + i + " is wrong");
		}
	}
	
	inline function Assert(flag_:Bool, mes_:String)
	{
		if (!flag_)
		{
			trace( "ERROR: " + mes_);
			throw "";
		}
	}
	
	public static function main()
	{
		new Main();
	}
}