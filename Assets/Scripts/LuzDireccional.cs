using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class LuzDireccional : MonoBehaviour
{
    public GameObject luz;

    public Color color = new Color(1, 1, 1);
    public Color intensity = new Color(0.5f, 0.5f, 0.5f);
    public Material[] materiales;

    // Start is called before the first frame update
    void Start()
    {
        materiales = Resources.LoadAll("Materiales", typeof(Material)).Cast<Material>().ToArray();
    }

    // Update is called once per frame
    void Update()
    {
        foreach (Material material in materiales)
        {
            material.SetVector("_DirectionalLightDirection_w", luz.transform.up);
            material.SetColor("_DirectionalLightColor", color);
            material.SetColor("_DirectionalLightIntensity", intensity);
        }
    }
}
