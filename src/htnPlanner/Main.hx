package htnPlanner;

import de.polygonal.ds.Heapable;
import de.polygonal.ds.Heap;
import haxe.Timer;

class HeapTest implements Heapable<HeapTest>
{
	public var name:String = null;
	
	public var value:Float;
	public var position:Int;
	
	public var depth:Int;

	public function new(name_:String, value_:Float, depth_:Int )
	{
		name = name_;
		value = value_;
		depth = depth_;
	}

	public function compare(other:HeapTest):Int
	{
		
		return other.value - value == 0 ? other.depth - depth : other.value - value < 0 ? -1 : 1;
	}

	public function toString():String
	{
		return "" + value;
	}
}

/**
 * ...
 * @author Michael Stephens
 */
class Main 
{
	
	var domainLocation:String = "pddlexamples/IPC3/Tests1/DriverLog/Strips/driverlog.pddl";
	var problemLocation:String = "pddlexamples/IPC3/Tests1/DriverLog/Strips/pfile1";
	var domain:Domain;
	var problem:Problem;

	var state:State = new State();
	
	public function new()
	{
		
		/*var heap:Heap<HeapTest> = new Heap<HeapTest>();
		
		//heap.add(new HeapTest("a", 0, 0));
		//heap.add(new HeapTest("b", 0, 1));
		//heap.add(new HeapTest("c", 0, 1));
		//heap.add(new HeapTest("d", 1.1, 0));
		//heap.add(new HeapTest("e", 2, 0));
		//heap.add(new HeapTest("f", 2, 0));
		//heap.add(new HeapTest("g", 3, 0));
		//heap.add(new HeapTest("h", 3, 1));
		
		for (i in 0...100)
		{
			heap.add(new HeapTest("test", Math.random() * 101, 0));
		}
		
		for (i in 0...heap.size())
		{
			trace(heap.top().value + " : " + heap.top().position + " __ " + heap.pop().value);
		}*/
		
		domain = new Domain(domainLocation);
		problem = new Problem(problemLocation, domain);
		
		var start = Timer.stamp();
		
		var planner:Planner = new Planner();
		var array:Array<PlannerActionNode> = planner.FindPlan(domain, problem);
		
		trace(Timer.stamp() - start);
		
		trace("length: " + array.length);
		
		for (i in 0...array.length)
		{
			trace(array[i].action.GetName() + " _ " + array[i].params.toString());
		}
		
		/*var action = domain.GetAction("drive");
		
		var initState = problem.GetClonedInitialState();
		
		action.SetParameter("?t", "truck1", "truck", domain);
		
		action.SetParameter("?from", "l3", "location", domain);
		action.SetParameter("?to", "l1", "location", domain);
		
		action.SetParameter("?t1", "t0", "time", domain);
		action.SetParameter("?t2", "t1", "time", domain);
		
		trace(action.Evaluate(initState, domain));
		initState.Print();
		var newState:State = action.Execute(initState, domain);
		newState.Print();
		
		trace(initState.GenerateStateHash());
		trace(newState.GenerateStateHash());*/
	}
	
	public static function main()
	{
		new Main();
	}
}