package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class State
{
	
	var relations:Map<String, Map<String, Array<String>>>;

	public function new() 
	{
		relations = new Map<String, Map<String, Array<String>>>();
	}
	
	public function AddRelation(a_:String, b_:String, c_:String)
	{
		AddRelationArray([a_, b_, c_]);
	}
	
	public function AddRelationArray(relations_:Array<String>)
	{
		if (relations_ == null || relations_.length == 0)
		{
			return;
		}
		
		if (!relations.exists(relations_[0])) // index 0 exists
		{
			relations.set(relations_[0], new Map<String, Array<String>>());
		}
		
		if (relations_.length == 1) // if its one large, dont go further
		{
			return;
		}
		
		var map:Map<String, Array<String>> = relations.get(relations_[0]);
		
		if (!map.exists(relations_[1]))
		{
			map.set(relations_[1], new Array<String>());
		}
		
		if (relations_.length == 2) // again, return if we have no more
		{
			return;
		}
		
		var array:Array<String> = map.get(relations_[1]);
		var leftovers:Array<String> = relations_.slice(2);
		
		for (i in leftovers)
		{
			if (Contains(array, i) == -1) // add any that are not in the relations
			{
				array.push(i);
			}
		}
		
	}
	
	public function Exists(relation_:Array<String>):Bool
	{
		if (relation_ == null || relation_.length == 0)
		{
			return false;
		}
		
		var keyA:String = relation_[0]; // we can guarantee the relation has a first term
		
		if (!relations.exists(keyA))
		{
			return false;
		}
		else if (relation_.length == 1) // since we tested for the first key and it exists, test to see if it is only 1 element long
		{
			return true;
		}
		
		var keyB:String = relation_[1]; // we can now guarantee it has a second term
		
		if (!relations.get(keyA).exists(keyB))
		{
			return false; // keyB does not exist
		}
		else if (relation_.length == 2) // same as above, if its two elements long, success
		{
			return true;
		}
		
		// now we can do a straight comparison into the final storage array
		var elementsLeft:Array<String> = relation_.slice(2); // get the rest of the elements
		var finalStorage:Array<String> = relations.get(keyA).get(keyB);
		
		for (i in elementsLeft)
		{
			if (Contains(finalStorage, i) == -1) // if this element does not exist, the precondition failed.
			{
				return false;
			}
		}
		
		return true; // we made it through the rest of the preconditions without failing
		
	}
	
	public function Get1(relation_:String):Map<String, Array<String>>
	{
		return relations.get(relation_);
	}
	
	public function Get2(relationA_:String, relationB_:String):Array<String>
	{
		if (relations.exists(relationA_))
		{
			return relations.get(relationA_).get(relationB_);
		}
		
		return null;
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

}