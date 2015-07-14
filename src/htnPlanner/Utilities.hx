package htnPlanner;

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
	
}