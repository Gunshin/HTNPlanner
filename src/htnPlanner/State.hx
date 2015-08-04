package htnPlanner;

import sys.io.File;
import sys.io.FileOutput;

import haxe.ds.HashMap;
import haxe.ds.StringMap;

/**
 * ...
 * @author Michael Stephens
 */
class State
{
	
	var relations:Map<String, Bool> = new StringMap<Bool>();
	var functions:Map<String, Int> = new StringMap<Int>();

	public function new() 
	{
	}

	public function AddRelation(relation_:String):Void
	{
		if (relation_ == null || relation_.length == 0)
		{
			throw "relation is null";
		}
		
		if (!Exists(relation_))
		{
			relations.set(relation_, true);
		}
		
	}
	
	public function RemoveRelation(relation_:String):Bool
	{
		
		if (relation_ == null || relation_.length == 0)
		{
			throw "relation is null";
		}
		
		return relations.remove(relation_);
	}
	
	public function Exists(relation_:String):Bool
	{
		if (relation_ == null || relation_.length == 0)
		{
			throw "relation_ is null or empty";
		}
		
		return relations.exists(relation_);
	}
	
	public function GetMatching(relation_:String):Array<String>
	{
		
		if (relation_ == null || relation_.length == 0)
		{
			throw "relation_ is null or empty";
		}
		
		var matchingRelations:Array<String> = new Array<String>();
		
		//check each element of the relation list
		for (i in relations.keys())
		{
			if (i.indexOf(relation_) > -1)
			{
				matchingRelations.push(i);
			}
		}
		
		return matchingRelations;
	}
	
	public function SetFunction(functionID_:String, value_:Int)
	{
		functions.set(functionID_, value_);
	}
	
	public function GetFunction(functionID_:String):Int
	{
		return functions.get(functionID_);
	}
	
	public function Print():Void
	{
		var fo:FileOutput = File.append("output.txt", false);
		fo.writeString("\n\n\n\n\n\n\n\n");
		fo.writeString("{ relations: " + relations.toString() + " }");
		fo.writeString("\n");
		fo.writeString("{ functions: " + functions.toString() + " }");
		fo.flush();
		fo.close();
	}
	
	public function Clone():State
	{
		var newState:State = new State();
		
		for (i in relations.keys())
		{
			newState.AddRelation(i);
		}
		
		for (i in functions.keys())
		{
			newState.SetFunction(i, GetFunction(i));
		}
		
		return newState;
	}
	
	public function GenerateStateHash():Int
	{
		var array:Array<Int> = new Array<Int>();
		
		for (i in relations.keys())
		{
			array.push(Utilities.StringHash(i));
		}
		
		for (i in functions.keys())
		{
			array.push(Utilities.StringHash(i + GetFunction(i)));
		}
		
		var hash:Int = Utilities.IntArrayHash(array);
		
		return hash;
	}
	
	public function ToString():String
	{
		var string:String = "[relations:[";
		
		for (i in relations.keys())
		{
			string += "[" + i + "],";
		}
		
		string += "], functions:[";
		
		for (i in functions.keys())
		{
			string += "[" + i + ":" + functions.get(i) + "],";
		}
		
		string += "]]";
		
		return string;
	}
	
	public function CompareState(state_:State):Array<String>
	{
		
		var nonMatching:Array<String> = new Array<String>();
		
		for (key in relations.keys())
		{
			if (!state_.Exists(key))
			{
				nonMatching.push(key);
			}
		}
		
		for (key in functions.keys())
		{
			if (state_.GetFunction(key) != GetFunction(key))
			{
				nonMatching.push(key + ": " + GetFunction(key));
			}
		}
		
		return nonMatching;
		
	}
}