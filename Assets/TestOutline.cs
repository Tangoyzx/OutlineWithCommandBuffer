using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class TestOutline : MonoBehaviour {
	public RenderTexture rt;
	public RenderTexture rt1;
	public RenderTexture rt2;
	public RenderTexture colorRT, depthRT;
	public Material mat;
	public Material blurMat;
	public Material subMat;

	public Material combineMat;
	private Camera _camera;
	private CommandBuffer _commandBuffer;
	private RenderTexture activeRT;
	private RenderBuffer screenColorBuffer;
	private RenderBuffer screenDepthBuffer;
	// Use this for initialization
	void Start () {
		_commandBuffer = new CommandBuffer();
		_commandBuffer.name = "TestOutline";
		GetComponent<Camera>().AddCommandBuffer(CameraEvent.AfterForwardOpaque, _commandBuffer);

		_camera = GetComponent<Camera>();
		_camera.depthTextureMode = DepthTextureMode.Depth;

		activeRT = RenderTexture.active;

		colorRT = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGB32);
		colorRT.filterMode = FilterMode.Bilinear;
		depthRT = new RenderTexture(Screen.width, Screen.height, 24, RenderTextureFormat.Depth);
		depthRT.filterMode = FilterMode.Bilinear;
		depthRT.SetGlobalShaderProperty("_DepthTexture");

		// rt = new RenderTexture(Mathf.FloorToInt(Screen.width * 0.5f), Mathf.FloorToInt(Screen.height * 0.5f), 0, RenderTextureFormat.ARGB32);
		rt = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGB32);
		rt.filterMode = FilterMode.Bilinear;

		// rt1 = new RenderTexture(Mathf.FloorToInt(Screen.width * 0.5f), Mathf.FloorToInt(Screen.height * 0.5f), 0, RenderTextureFormat.ARGB32);
		rt1 = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGB32);
		rt1.filterMode = FilterMode.Bilinear;

		// rt2 = new RenderTexture(Mathf.FloorToInt(Screen.width * 0.5f), Mathf.FloorToInt(Screen.height * 0.5f), 0, RenderTextureFormat.ARGB32);
		rt2 = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGB32);
		rt2.filterMode = FilterMode.Bilinear;

		subMat.SetTexture("_SubTex", rt);
		combineMat.SetTexture("_SecTex", rt1);
	}

	void OnPreRender() {
		_commandBuffer.Clear();
		_commandBuffer.SetRenderTarget(rt);
		_commandBuffer.ClearRenderTarget(false, true, new Color(0, 0, 0, 0));
		var list = GameObject.FindObjectsOfType<Outliner>();
		var matList = new List<Matrix4x4>();
		foreach(var outliner in list)
		{
			var mesh = outliner.GetComponent<MeshFilter>().mesh;
			_commandBuffer.DrawMesh(mesh, outliner.transform.localToWorldMatrix, mat, 0, 0, outliner.GetBlock());
		}

		_commandBuffer.Blit(rt, rt1, blurMat, 0);
		_commandBuffer.Blit(rt1, rt2, blurMat, 1);

		_commandBuffer.Blit(rt2, rt1, subMat);

		GetComponent<Camera>().SetTargetBuffers(colorRT.colorBuffer, depthRT.depthBuffer);
	}	
	
	void OnPostRender() {
		Graphics.SetRenderTarget(activeRT);
		Graphics.Blit(colorRT, RenderTexture.active, combineMat);
	}
}
