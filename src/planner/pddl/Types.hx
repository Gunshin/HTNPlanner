package planner.pddl;

import haxe.ds.HashMap;
import haxe.ds.StringMap;

/**
 * ...
 * @author Michael Stephens
 */
class Types
{

	var typesHierarchy:Map<String, String> = new StringMap<String>();
	
	var types:Array<String> = new Array<String>();
	
	public function new(rawNode:RawTreeNode) 
	{
		var currentSetOfValues:Array<String> = new Array<String>();
		
		// this indicator is used to define a type being set for values. it is flipped when a "-" is met
		var indicator:Bool = false;
		
		var index:Int = 0;
		while (index < rawNode.children.length) // dont ask about god damn while loops since someone on the haxe development team had the bright idea of 
		// not allowing normal for loops. cant use foreach since they dont allow manual changing of the iterator
		{
			// check to see if the current element is empty
			if (Utilities.Compare(rawNode.children[index].value, "") != 0)
			{
				// indicator value declaring that the next element is a type
				if (Utilities.Compare(rawNode.children[index].value, "-") == 0)
				{
					indicator = true;
				}
				else
				{
					
					if (!indicator)
					{
						// indicator has not been set yet, so the next value is not the type
						currentSetOfValues.push(rawNode.children[index].value);
						AddType(rawNode.children[index].value);
					}
					else
					{
						// indicator has been set, so lets set all our current values to the type
						
						for (i in currentSetOfValues)
						{
							// need to trim since the endline character might be included here
							SetSuperType(i, StringTools.trim(rawNode.children[index].value));
						}
						
						AddType(rawNode.children[index].value); // add super type since some plans do not specify super types as a type (we would miss it without this)
						
						currentSetOfValues = new Array<String>(); // reset the array (why is there no clear function? T_T)
						
						indicator = false;
					}
				}
			}
			
			index++;
		}
	}
	
	public function AddType(type_:String)
	{
		if (Utilities.Contains(types, type_) == -1) // if its not in the list
		{
			types.push(type_);
		}
	}
	
	public function SetSuperType(type_:String, superType_:String)
	{
		typesHierarchy.set(type_, superType_);
	}
	
	public function GetSuperType(type_:String):String
	{
		return typesHierarchy.get(type_);
	}
	
	public function GetTypesHierarchy(type_:String):Array<String>
	{
		var typeList:Array<String> = new Array<String>();
		typeList.push(type_);
		
		var type:String = typesHierarchy.get(type_);
		while (type != null)
		{
			typeList.push(type);
			
			type = typesHierarchy.get(type);
		}
		
		return typeList;
	}
	
	public function Exists(type_:String):Bool
	{
		for (i in types)
		{
			if (Utilities.Compare(type_, i) == 0)
			{
				return true;
			}
		}
		
		return false;
	}
	
	public function GetAllTypes():Array<String>
	{
		return types;
	}
}