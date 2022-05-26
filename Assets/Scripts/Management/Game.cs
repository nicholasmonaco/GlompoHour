using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class Game {
    public static GameManager Manager;





    #region Input
    public static InputActions Input { get; private set; } = new _InputActions();

    // Modified controls class to enable on construction
	private class _InputActions : InputActions {
		public _InputActions() : base() {
			Enable();
		}
	}

	#endregion
}
