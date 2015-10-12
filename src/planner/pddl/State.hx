package planner.pddl;

import de.polygonal.ds.BST;
import de.polygonal.ds.Comparable;
import planner.pddl.Domain;
import planner.pddl.Pair;
import sys.io.File;
import sys.io.FileOutput;

class RelationWrapper implements Comparable<RelationWrapper>
{
	public var value:String = null;
	
	public function new(value_:String)
	{
		value = value_;
	}
	
	public function compare(other_:RelationWrapper):Int
	{
		return Utilities.Compare(value, other_.value);
	}
}

class FunctionWrapper implements Comparable<FunctionWrapper>
{
	public var func:String = null;
	public var value:Int = 0;
	
	public function new(func_:String, value_:Int)
	{
		func = func_;
		value = value_;
	}
	
	public function compare(other_:FunctionWrapper):Int
	{
		return Utilities.Compare(func, other_.func);
	}
}

/**
 * ...
 * @author Michael Stephens
 */
class State
{
	
	var relationsMap:Map<String, RelationWrapper> = new Map<String, RelationWrapper>();
	
	var functionsMap:Map<String, FunctionWrapper> = new Map<String, FunctionWrapper>();
	
	var objects:Map<String, Array<String>> = new Map<String, Array<String>>();

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
			var wrapper = new RelationWrapper(relation_);
			relationsMap.set(relation_, wrapper);
		}
		
	}
	
	public function RemoveRelation(relation_:String):Bool
	{
		
		if (relation_ == null || relation_.length == 0)
		{
			throw "relation is null";
		}
		
		if (!Exists(relation_))
		{
			return false;
		}
		
		relationsMap.remove(relation_);
		return true;
	}
	
	public function Exists(relation_:String):Bool
	{
		if (relation_ == null || relation_.length == 0)
		{
			throw "relation_ is null or empty";
		}
		
		return relationsMap.exists(relation_);
	}
	
	public function GetMatching(relation_:String):Array<String>
	{
		
		if (relation_ == null || relation_.length == 0)
		{
			throw "relation_ is null or empty";
		}
		
		var matchingRelations:Array<String> = new Array<String>();
		for (key in relationsMap.keys())
		{
			var relation:String = relationsMap.get(key).value;
			if (relation.indexOf(relation_) > -1)
			{
				matchingRelations.push(relation);
			}
		}
		
		return matchingRelations;
	}
	
	public function SetFunction(functionID_:String, value_:Int)
	{
		var func = new FunctionWrapper(functionID_, value_);
		functionsMap.set(functionID_, func);
	}
	
	public function GetFunction(functionID_:String):Int
	{
		if (functionID_ == null)
		{
			throw "Function is null: ";
		}
		
		if (!functionsMap.exists(functionID_))
		{
			SetFunction(functionID_, 0);
		}
		return functionsMap.get(functionID_).value;
	}
	
	public function Print():Void
	{
		var fo:FileOutput = File.append("output.txt", false);
		fo.writeString("\n\n\n\n\n\n\n\n");
		fo.writeString("{ relations: " + relationsMap.toString() + " }");
		fo.writeString("\n");
		fo.writeString("{ functions: " + functionsMap.toString() + " }");
		fo.flush();
		fo.close();
	}
	
	public function Clone():State
	{
		return CopyTo(new State());
	}
	
	/**
	 * This copies the state it is called on, to the state specified as a parameter
	 * @param	state_to_be_copied_to_
	 * @return The state that was copied to. Allows calling: var state:State = old_state.CopyTo(new State());
	 */
	public function CopyTo(state_to_be_copied_to_:State):State
	{		
		for (i in relationsMap.keys())
		{
			state_to_be_copied_to_.AddRelation(i);
		}
		
		for (i in functionsMap.keys())
		{
			state_to_be_copied_to_.SetFunction(i, GetFunction(i));
		}
		
		state_to_be_copied_to_.SetObjects(objects);
		
		return state_to_be_copied_to_;
	}
	
	public function GenerateStateHash():Int
	{
		var array:Array<Int> = new Array<Int>();
		
		{
			var relations:BST<RelationWrapper> = new BST<RelationWrapper>();
			for (key in relationsMap.keys())
			{
				relations.insert(relationsMap.get(key));
			}
			
			if (relations.size() > 0)
			{
				relations.root().inorder(function(treeNode_, dynamic_) {
					array.push(Utilities.StringHash(treeNode_.val.value));
					return true;
				});
			}
		}
		
		{
			var functions:BST<FunctionWrapper> = new BST<FunctionWrapper>();
			for (key in functionsMap.keys())
			{
				functions.insert(functionsMap.get(key));
			}
			if (functions.size() > 0)
			{
				functions.root().inorder(function(treeNode_, dynamic_) {
					array.push(Utilities.StringHash(treeNode_.val.func + treeNode_.val.value));
					return true;
				});
			}
		}
		
		var hash:Int = Utilities.IntArrayHash(array);
		
		return hash;
	}
	
	public function SetObjectsRaw(objArray_:Array<Pair<String, String>>, domain_:Domain)
	{
		for (type in domain_.GetTypes().GetAllTypes())
		{
			objects.set(type, new Array<String>());
		}
		
		for (obj in objArray_)
		{
			if (!domain_.GetTypes().Exists(obj.b))
			{
				throw "obj: " + obj.a + " and its type: " + obj.b + " do not exist in the domain types";
			}
			
			var typeList:Array<String> = domain_.GetTypes().GetTypesHierarchy(obj.b);
			for (type in typeList)
			{
				var objectsArray:Array<String> = objects.get(type);
				objectsArray.push(obj.a);
			}
		}
		
		// we also need to iterate through the domains constant list if it has one, and add it to the object list (for now)
		for (constant in domain_.GetConstants())
		{
			var typeList:Array<String> = domain_.GetTypes().GetTypesHierarchy(constant.b);
			
			for (type in typeList)
			{
				var objectsArray:Array<String> = objects.get(type);
				objectsArray.push(constant.a);
			}
		}
	}
	
	public function SetObjects(objects_:Map<String, Array<String>>)
	{
		objects = new Map<String, Array<String>>();
		
		for (key in objects_.keys())
		{
			objects.set(key, objects_.get(key));
		}
	}

	public function GetObjectsOfType(type_:String):Array<String>
	{
		return objects.get(type_);
	}
	
	public function toString():String
	{
		var string:String = "{relations:[";
		
		for (i in relationsMap.keys())
		{
			string += "{" + i + "},";
		}
		
		string = string.substr(0, string.length - 1);
		string += "], functions:[";
		
		for (i in functionsMap.keys())
		{
			string += "{" + i + ":" + functionsMap.get(i).value + "},";
		}
		
		string += "]}";
		
		return string;
	}
	
	public function CompareState(state_:State):Array<String>
	{
		
		var nonMatching:Array<String> = new Array<String>();
		
		for (key in relationsMap.keys())
		{
			if (!state_.Exists(key))
			{
				nonMatching.push(key);
			}
		}
		
		for (key in functionsMap.keys())
		{
			if (state_.GetFunction(key) != GetFunction(key))
			{
				nonMatching.push(key + ": " + GetFunction(key));
			}
		}
		
		return nonMatching;
	}
	
	public function Equals(state_:State):Bool
	{
		return CompareState(state_).length == 0 && state_.CompareState(this).length == 0;
	}
	
}