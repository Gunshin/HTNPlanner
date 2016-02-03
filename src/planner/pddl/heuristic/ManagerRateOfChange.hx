package planner.pddl.heuristic;
import haxe.macro.ExprTools.ExprArrayTools;


// i really need to go through and rename things, this shit is getting out of hand
class ROFStorageHelper
{
	// maps the depth to the function. slightly easier to find things this way
	var map:Map<Int, FunctionRateOfChange> = new Map<Int, FunctionRateOfChange>();
	
	//the lowest level rof. so we can easily see which is the first instance of the action
	var min:FunctionRateOfChange = null;
	var best:FunctionRateOfChange = null;
	public function new()
	{
		
	}
	
	public function Add(function_rate_of_change_:FunctionRateOfChange)
	{
		var existing:FunctionRateOfChange = map.get(function_rate_of_change_.state_level);
		if (existing == null || IsBetterFunctionRateOfChange(function_rate_of_change_, existing))
		{
			map.set(function_rate_of_change_.state_level, function_rate_of_change_);
			
			// we already know that the above if statement means that this scope/function_rate_of_change is better,
			// we just need to make sure its the lowest too.
			if (min == null || function_rate_of_change_.state_level <= min.state_level)
			{
				min = function_rate_of_change_;
			}
		}
	}
	
	public function Calculate()
	{
		
		for (key in map.keys())
		{
			var obj:FunctionRateOfChange = map.get(key);
			if (best == null || IsBetterFunctionRateOfChange(obj, best))
			{
				best = obj;
			}
		}
		
	}
	
	public function GetBest():FunctionRateOfChange
	{
		return best;
	}
	
	public function GetAll():Array<FunctionRateOfChange>
	{
		var all:Array<FunctionRateOfChange> = new Array<FunctionRateOfChange>();
		for (obj in map)
		{
			all.push(obj);
		}
		return all;
	}
	
	static public function IsBetterFunctionRateOfChange(target_:FunctionRateOfChange, comparison_:FunctionRateOfChange):Bool
	{
		return comparison_.rate_of_change > 0 && comparison_.rate_of_change < target_.rate_of_change ||
			comparison_.rate_of_change < 0 && comparison_.rate_of_change > target_.rate_of_change;
	}
	
}

/**
 * ...
 * @author 
 */
class ManagerRateOfChange
{
	// first map is function name to actions
	// second map is action name to storage helper
	var action_function_mapping:Map<String, Map<String, ROFStorageHelper>> = new Map<String, Map<String, ROFStorageHelper>>();

	public function new() 
	{
		
	}
	
	public function AddRateOfChange(rate_of_change_:FunctionRateOfChange)
	{
		
		var function_map:Map<String, ROFStorageHelper> = action_function_mapping.get(rate_of_change_.function_name);
		if (function_map == null)
		{
			function_map = new Map<String, ROFStorageHelper>();
			action_function_mapping.set(rate_of_change_.function_name, function_map);
		}
		
		var action_ID:String = rate_of_change_.action.GetNonIntegerParameterActionTransform();
		var helper:ROFStorageHelper = function_map.get(action_ID);
		if (helper == null)
		{
			helper = new ROFStorageHelper();
			function_map.set(action_ID, helper);
		}
		
		helper.Add(rate_of_change_);
		
	}
	
	public function GetBest(func_names_:Array<String>, max_depth_:Int):Array<FunctionRateOfChange>
	{
		var best_array:Array<FunctionRateOfChange> = new Array<FunctionRateOfChange>();
		for (func_name in func_names_)
		{
			for (storage in action_function_mapping.get(func_name))
			{
				best_array.push(storage.GetBest());
			}
		}
		
		return best_array;
		
	}
	
	/**
	 * This sets the manager so that the best action for each function is found
	 */
	public function Calculate()
	{
		for (map in action_function_mapping)
		{
			for (sub_map in map)
			{
				sub_map.Calculate();
			}
		}
	}
	
	public function GetAllFunctions():Array<FunctionRateOfChange>
	{
		var all:Array<FunctionRateOfChange> = new Array<FunctionRateOfChange>();
		for (key in action_function_mapping.keys())
		{
			all = all.concat(GetAllFromFunction(key));
		}
		
		return all;
	}
	
	public function GetAllFromFunction(function_name_:String):Array<FunctionRateOfChange>
	{
		var all:Array<FunctionRateOfChange> = new Array<FunctionRateOfChange>();
		var map:Map<String, ROFStorageHelper> = action_function_mapping.get(function_name_);
		for (storage in map)
		{
			all = all.concat(storage.GetAll());
		}
		
		return all;
	}
	
}