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
			throw "NullPointerException in ContainsStringArray";
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
	
}