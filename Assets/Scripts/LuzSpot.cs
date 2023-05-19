using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class LuzSpot : MonoBehaviour
{

    public GameObject luz;
    public Color color = new Color(1,1,1);
    public float intensity = 0.5f;

    public float aperture = 45;

    public Material[] materiales;

    // Start is called before the first frame update
    void Start()
    {
        materiales = Resources.LoadAll("Materiales", typeof(Material)).Cast<Material>().ToArray();
    }

    // Update is called once per frame
    void Update()
    {
        aperture = Mathf.Clamp(aperture, 0.0f, 90.0f);
        intensity = Mathf.Clamp(intensity, 0.0f, 1.0f);
        foreach (Material material in materiales)
        {
            material.SetVector("_SpotLightPosition_w", luz.transform.position);
            material.SetVector("_SpotLightDirection_w", luz.transform.up);
            material.SetFloat("_SpotAperture", aperture);
            material.SetColor("_SpotLightColor", color);
            material.SetFloat("_SpotLightIntensity", intensity);
        }
    }
}
