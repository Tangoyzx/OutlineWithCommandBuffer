using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Outliner : MonoBehaviour {
	public MaterialPropertyBlock mpb;
	public Color color = Color.red;
	void Awake() {
		mpb = new MaterialPropertyBlock();
	}

	public MaterialPropertyBlock GetBlock() {
		mpb.SetColor("_OutlineColor", color);
		return mpb;
	}
}
