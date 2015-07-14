package htnPlanner;
import haxe.ds.StringMap;

/**
 * ...
 * @author Michael Stephens
 */
class Utilities
{
	public inline static function Compare(a_:String, b_:String):Int 
    {
        return if ( a_ < b_ ) -1 else if ( a_ > b_ ) 1 else 0;
    }
	
	/*
	 * Checks to see if arrayA_ contains the elements of arrayB_
	 * 
	 */
	public static function ContainsStringArray(arrayA_:Array<String>, arrayB_:Array<String>):Bool
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
	public static function Contains(array_:Array<String>, element_:String):Int
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
	
	public static function GetScope(string_:String, start_:Int):String
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
	
	public static function GetNamedScope(name_:String, string_:String):String
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
	
	public static function GenerateValueTypeMap(strings_:Array<String>):Map<String, String>
	{
		var map:Map<String, String> = new StringMap<String>();
		
		// used to cache which values are the same, so that when a type is hit, we can set them correctly
		var currentSetOfValues:Array<String> = new Array<String>();
		
		// this indicator is used to define a type being set for values. it is flipped when a "-" is met
		var indicator:Bool = false;
		
		// set it to 1 since the first element in split is ":types"
		var index:Int = 1;
		while (index < strings_.length) // dont ask about god damn while loops since someone on the haxe development team had the bright idea of 
		// not allowing normal for loops. cant use foreach since they dont allow manual changing of the iterator
		{
			// check to see if the current element is empty
			if (Utilities.Compare(strings_[index], "") != 0)
			{
				// indicator value declaring that the next element is a type
				if (Utilities.Compare(strings_[index], "-") == 0)
				{
					indicator = true;
				}
				else
				{
					
					if (!indicator)
					{
						// indicator has not been set yet, so the next value is not the type
						currentSetOfValues.push(strings_[index]);
					}
					else
					{
						// indicator has been set, so lets set all our current values to the type
						
						for (i in currentSetOfValues)
						{
							// need to trim since the endline character might be included here
							map.set(i, StringTools.trim(strings_[index]));
						}
						
						currentSetOfValues = new Array<String>(); // reset the array (why is there no clear function? T_T)
						
						indicator = false;
					}
				}
			}
			
			index++;
		}
		
	}
	
}