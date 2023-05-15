using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class LuzPoint : MonoBehaviour
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
            material.SetVector("_PointLightPosition_w", luz.transform.position);
            material.SetColor("_PointLightColor", color);
            material.SetColor("_PointLightIntensity", intensity);
        }
    }
}
