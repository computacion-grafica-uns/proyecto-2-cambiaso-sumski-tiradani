using JetBrains.Annotations;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class ManejadorLuces : MonoBehaviour
{
    public GameObject directionalLight;
    public GameObject pointLight;
    public GameObject spotLight;

    public Material[] materiales;

    // Start is called before the first frame update
    void Start()
    {
        materiales = Resources.LoadAll("Materiales", typeof(Material)).Cast<Material>().ToArray();
    }

    // Update is called once per frame
    void Update()
    {
        
        // Directional light
        if (Input.GetKeyDown(KeyCode.Alpha1))
        {

            if (directionalLight.activeSelf)
            {
                directionalLight.SetActive(false);
                foreach (Material material in materiales)
                {
                    material.SetVector("_DirectionalLightDirection_w", new Vector4(0, 0, 0, 1));
                }
            } else
            {
                directionalLight.SetActive(true);
            }

        }
        // Point light
        if (Input.GetKeyDown(KeyCode.Alpha2))
        {

            if (pointLight.activeSelf)
            {
                pointLight.SetActive(false);
                foreach (Material material in materiales)
                {
                    material.SetColor("_PointLightColor", Color.black);
                }
            }
            else
            {
                pointLight.SetActive(true);
            }
        }
        // SpotLight
        if (Input.GetKeyDown(KeyCode.Alpha3))
        {

            if (spotLight.activeSelf)
            {
                spotLight.SetActive(false);
                foreach (Material material in materiales)
                {
                    material.SetColor("_SpotLightColor", Color.black);
                }
            }
            else
            {
                spotLight.SetActive(true);
            }

        }
        
    }
}
