using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class SmearEffect : MonoBehaviour
{
	Material _smearMat = null;
	public Material smearMat
	{
		get
		{
			if (!_smearMat)
				_smearMat = GetComponent<Renderer>().material;
			if (!_smearMat.HasProperty("_PrevPosition"))
				_smearMat.shader = Shader.Find("Sprites/Sprite-Smear-Basic");
			return _smearMat;
		}
	}
    
    private void Update()
    {
        //update position
        Vector3 direction = new Vector3(Mathf.Sin(Time.time), Mathf.Cos(Time.time));
        transform.position += direction  * Time.deltaTime * 2;

        //set shader properties
        smearMat.SetVector("_Position", transform.position);
        smearMat.SetVector("_SmearDirection", direction * 16);
    }
}
