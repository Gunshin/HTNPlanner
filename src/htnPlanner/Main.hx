package htnPlanner;

import de.polygonal.ds.BinaryTreeNode;
import de.polygonal.ds.BST;
import de.polygonal.ds.Comparable;

import haxe.Timer;

class Wrapper implements Comparable<Wrapper>
{
	public var value:String = null;
	
	public function new(value_:String)
	{
		value = value_;
	}
	
	public function compare(other_:Wrapper):Int
	{
		return Utilities.Compare(value, other_.value);
	}
}

/**
 * ...
 * @author Michael Stephens
 */
class Main 
{
	
	var domainLocation:String = "pddlexamples/IPC3/Tests1/DriverLog/HardNumeric/driverlogHardNumeric.pddl";
	var problemLocation:String = "pddlexamples/IPC3/Tests1/DriverLog/HardNumeric/pfile3";
	var domain:Domain;
	var problem:Problem;
	
	public function new()
	{
		
		/*var bst:BST<Wrapper> = new BST<Wrapper>();
		
		bst.insert(new Wrapper("at truck1 s0"));
		bst.insert(new Wrapper("at driver1 s0"));
		bst.insert(new Wrapper("empty truck1"));
		bst.insert(new Wrapper("at driver2 p1-2"));
		bst.insert(new Wrapper("driving driver1 truck1"));
		bst.insert(new Wrapper("link s0 s1"));
		bst.insert(new Wrapper("path p1-2 s1"));
		bst.insert(new Wrapper("at driver1 p1-2"));
		
		bst.root().inorder(function(treeNode_, dynamic_) {
			trace(treeNode_.val.value);
			return true;
		});*/
		
		domain = new Domain(domainLocation);
		problem = new Problem(problemLocation, domain);
		
		var start = Timer.stamp();
		
		var planner:Planner = new Planner();
		var array:Array<PlannerActionNode> = planner.FindPlan(domain, problem);
		
		trace(Timer.stamp() - start);
		
		trace("length: " + array.length);
		
		for (i in 0...array.length)
		{
			trace(array[i].GetActionTransform());
		}
		
	}
	
	public static function main()
	{
		new Main();
	}
}