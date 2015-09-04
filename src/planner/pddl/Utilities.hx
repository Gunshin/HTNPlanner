package planner.pddl;
import haxe.ds.StringMap;
import planner.pddl.Pair;
import planner.pddl.RawTreeNode;
import sys.io.FileOutput;

import sys.FileSystem;
import sys.io.File;
import sys.io.FileInput;

/**
 * ...
 * @author Michael Stephens
 */
class Utilities
{
	static public inline function Compare(a_:String, b_:String):Int 
    {
        return if ( a_ < b_ ) -1 else if ( a_ > b_ ) 1 else 0;
    }
	
	/*
	 * Checks to see if arrayA_ contains the elements of arrayB_
	 * 
	 */
	static public function ContainsStringArray(arrayA_:Array<String>, arrayB_:Array<String>):Bool
	{
		if (arrayA_ == null || arrayB_ == null)
		{
			throw "NullPointerException in ContainsStringArray: arrayA_: " + (arrayA_ == null) + " arrayB_: " + (arrayB_ == null);
		}
		
		if (arrayA_.length < arrayB_.length || arrayA_.length == 0 || arrayB_.length == 0)
		{
			return false;
		}
		
		for (i in 0...arrayB_.length)
		{
			
			if (Compare(arrayA_[i], arrayB_[i]) != 0)
			{
				return false;
			}
			
		}
		return true;
	}
	
	/*
	 * returns -1 if element is not contained in array, otherwise returns its index
	 */
	static public function Contains(array_:Array<String>, element_:String):Int
	{
		for (i in 0...array_.length)
		{
			if (Utilities.Compare(array_[i], element_) == 0)
			{
				return i;
			}
		}
		
		return -1;
	}
	
	static public function GetScope(string_:String, start_:Int):String
	{
		var value:String = "";
		
		var depth:Int = 0;
		var i:Int = start_;
		while (i < string_.length)
		{
			//need to make sure that we start the scope search on a bracket so that we do not immediately break
			if (string_.charAt(i) == '(')
			{				
				depth++;
			}
			else if(string_.charAt(i) == ')')
			{
				depth--;
			}
			
			value += string_.charAt(i);
			i++;
			
			// if we are back on the bottom layer, eg. at the end of the scope
			if (depth == 0)
			{
				break;
			}
		}
		
		return value;
	}
	
	static public function GetScopedContents(string_:String):Array<String>
	{
		var returnee:Array<String> = new Array<String>();
		
		if (string_.charAt(0) == '(')
		{
			string_ = string_.substring(1, string_.length);
		}
		
		if (string_.charAt(string_.length - 1) == ')')
		{
			string_ = string_.substring(0, string_.length - 1);
		}
		
		var split:Array<String> = string_.split(" ");
		
		/*for (s in split)
		{
			trace(s);
		}*/
		
		var tempElementHolder:Array<String> = new Array<String>();
		var holdElements:Bool = false;
		var depth:Int = 0;
		
		for (element in split)
		{
			
			if (element.charAt(0) == '(' && element.charAt(element.length - 1) != ')')
			{
				holdElements = true;
				depth++;
				tempElementHolder.push(element);
			}
			else if (element.charAt(0) != '(' && element.charAt(element.length - 1) == ')')
			{
				depth--;
				tempElementHolder.push(element);
				
				if (depth == 0)
				{
					holdElements = false;
					
					var fullElement:String = "";
					for (ele in tempElementHolder)
					{
						fullElement += " " + ele;
					}
					
					returnee.push(StringTools.trim(fullElement));
					tempElementHolder = new Array<String>();
				}
			}
			else if (holdElements)
			{
				tempElementHolder.push(element);
			}
			else if (Compare(element, "") != 0)
			{
				returnee.push(element);
			}
			
		}
		
		return returnee;
	}
	
	static public function GetNamedScope(name_:String, string_:String):String
	{
		var index:Int = string_.indexOf(name_);
		
		if (index == -1)
		{
			throw "name_ cannot be found";
		}
		
		// this looks for the next occurence of "(" after our name_ point. should always be the correct scope start
		var startIndexOfScope:Int = string_.indexOf("(", index);
		
		return GetScope(string_, startIndexOfScope);
	}
	
	static public function GenerateValueTypeMap(nodes_:Array<RawTreeNode>):Array<Pair<String, String>>
	{
		var returnPairs:Array<Pair<String, String>> = new Array<Pair<String, String>>();
		
		// used to cache which values are the same, so that when a type is hit, we can set them correctly
		var currentSetOfValues:Array<String> = new Array<String>();
		
		// this indicator is used to define a type being set for values. it is flipped when a "-" is met
		var indicator:Bool = false;
		
		var index:Int = 0;
		while (index < nodes_.length) // dont ask about god damn while loops since someone on the haxe development team had the bright idea of 
		// not allowing normal for loops. cant use foreach since they dont allow manual changing of the iterator
		{
			// check to see if the current element is empty
			if (Utilities.Compare(nodes_[index].value, "") != 0)
			{
				// indicator value declaring that the next element is a type
				if (Utilities.Compare(nodes_[index].value, "-") == 0)
				{
					indicator = true;
				}
				else
				{
					
					if (!indicator)
					{
						// indicator has not been set yet, so the next value is not the type
						currentSetOfValues.push(nodes_[index].value);
					}
					else
					{
						// indicator has been set, so lets set all our current values to the type
						
						for (i in currentSetOfValues)
						{
							// need to trim since the endline character might be included here
							returnPairs.push(new Pair(i, StringTools.trim(nodes_[index].value)));
						}
						
						currentSetOfValues = new Array<String>(); // reset the array (why is there no clear function? T_T)
						
						indicator = false;
					}
				}
			}
			
			index++;
		}
		
		return returnPairs;
	}
	
	static public function CleanFileImport(filePath_:String):String
	{
		if (!FileSystem.exists(filePath_))
		{
			throw "File: " + filePath_ + " does not exist! wrong path?";
		}
		
		var fileContent:String = File.getContent(filePath_);

		var lines:Array<String> = fileContent.split("\n");
		
		var finalString:String = "";
		
		for (i in lines)
		{
			if (i.length > 1 || !StringTools.isSpace(i, 0))
			{
				var line:String = StripComments(StringTools.trim(i));
				line = AddNeccessarySpaces(line);
				finalString += " " + line;
			}
		}
		
		return StringTools.trim(finalString);
	}
	
	static function AddNeccessarySpaces(string_:String):String
	{
		
		var returnee:String = "";
		
		for (index in 0...string_.length)
		{
			returnee += string_.charAt(index);
			
			if (index + 1 < string_.length)
			{
				// if we have two closing or opening brackets together for scope closure, add spaces between them
				if ((string_.charAt(index) == '(' && string_.charAt(index + 1) == '(') ||
					(string_.charAt(index) == ')' && string_.charAt(index + 1) == ')')
				)
				{
					returnee += " ";
				}
			}
		}
		
		return returnee;
	}
	
	static function StripComments(string_:String):String
	{		
		var commentFree:String = "";
			
		for (index in 0...string_.length)
		{
			var char:String = string_.charAt(index);
			
			if (Compare(char, ";") == 0)
			{
				return commentFree;
			}
			
			commentFree += string_.charAt(index);
		}
		
		return commentFree;
	}
	
	//http://www.cse.yorku.ca/~oz/hash.html
	static public function StringHash(string_:String):Int
	{
		var hash:Int = 0;
		
        for(i in 0...string_.length)
		{
            hash = string_.charCodeAt(i) + (hash << 6) + (hash << 16) - hash;
		}
		
        return hash;
	}
	
	//same as above but using an interger array instead
	static public function IntArrayHash(array_:Array<Int>):Int
	{
		var hash:Int = 0;
			
        for(i in array_)
		{
            hash = i + (hash << 6) + (hash << 16) - hash;
		}
		
        return hash;
	}
	
}