package planner.pddl;
import de.polygonal.ds.Prioritizable;
import planner.pddl.State;

import de.polygonal.ds.BST;
import de.polygonal.ds.Comparable;

class FunctionBoundsWrapper implements Comparable<FunctionBoundsWrapper>
{
	public var name:String = null;
	public var value:Pair<Int, Int> = null;
	
	public function new(name_:String, value_:Pair<Int, Int>)
	{
		name = name_;
		value = value_;
	}
	
	public function compare(other_:FunctionBoundsWrapper):Int
	{
		return Utilities.Compare(name, other_.name);
	}
}


/**
 * ...
 * @author Michael Stephens
 */
class StateHeuristic extends State
{
	
	var functions_bounds:Map<String, Pair<Int, Int>> = new Map<String, Pair<Int, Int>>();

	public function new() 
	{
		super();
	}
	
	/**
	 * This should not in reality be called through a heuristic tree call, however,
	 * just to be safe i am overriding it
	 * @param	relation_
	 * @return
	 */
	override public function RemoveRelation(relation_:String):Bool 
	{
		return true;
	}
	
	override public function SetFunction(functionID_:String, value_:Int) 
	{
		super.SetFunction(functionID_, value_);
		
		SetFunctionBounds(functionID_, new Pair<Int, Int>(value_, value_));
	}
	
	public function SetFunctionBounds(functionID_:String, bounds_:Pair<Int, Int>)
	{
		if (!functions_bounds.exists(functionID_))
		{
			functions_bounds.set(functionID_, bounds_);
			return;
		}
		
		var bounds:Pair<Int, Int> = functions_bounds.get(functionID_);
		
		if (bounds_.a < bounds.a)
		{
			bounds.a = bounds.a;
		}
		if (bounds_.b > bounds.b)
		{
			bounds.b = bounds_.b;
		}
		
		//trace("function bounds count: " + functions_bounds.toString());
	}
	
	/**
	 * @param	functionID_
	 * @return
	 */
	public function GetFunctionBounds(functionID_:String):Pair<Int, Int> 
	{
		//trace("functionID_: " + functionID_);
		if (!functions_bounds.exists(functionID_))
		{
			var original_value:Int = GetFunction(functionID_);
			SetFunctionBounds(functionID_, new Pair(original_value, original_value));
		}
		
		return functions_bounds.get(functionID_);
	}
	
	override public function toString():String
	{
		var string:String = "{\"relations\":[";
		
		for (i in relationsMap.keys())
		{
			var split:Array<String> = i.split(" ");
			string += "{\"predicate\":\"" + split[0] + "\",\"parameters\":[";
			
			for (i in 1...split.length)
			{
				string += "\"" + split[i] + "\",";
			}
			
			string = string.substr(0, string.length - 1);
			string += "]},";
		}
		
		string = string.substr(0, string.length - 1);
		string += "],\n \"functions\":[";
		
		for (i in functionsMap.keys())
		{
			
			var split:Array<String> = i.split(" ");
			string += "{\"function\":\"" + split[0] + "\",\"parameters\":[";
			
			if (split.length > 1)
			{
				for (i in 1...split.length)
				{
					string += "\"" + split[i] + "\",";
				}
				
				string = string.substr(0, string.length - 1);
			}
			
			string += "],";
			
			string += "\"value\":" + functions_bounds.get(i) + "},";
		}
		
		string = string.substr(0, string.length - 1);
		string += "],\n \"objects\":[";
		
		for (i in objects.keys())
		{
			string += "{\"" + i + "\":[";
			
			var array:Array<String> = objects.get(i);
			for (ele in array)
			{
				string += "\"" + ele + "\",";
			}
			string = string.substr(0, string.length - 1);
			string += "]},";
		}
		
		string = string.substr(0, string.length - 1);
		string += "]}";
		
		return string;
	}

}