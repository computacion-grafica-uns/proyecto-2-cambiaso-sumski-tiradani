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


    public Color direcColor = new Color(0, 0, 1);
    public Color pointColor = new Color(0, 1, 0);
    public Color spotColor = new Color(1, 0, 0);

    Color oldPointLightColor;
    Color oldSpotLightColor;
    Vector4 oldDirectionalLightDirection;


    // Start is called before the first frame update
    void Start()
    {
        materiales = Resources.LoadAll("Materiales", typeof(Material)).Cast<Material>().ToArray();
    }

    // Update is called once per frame
    void Update()
    {
        // TO - DO

        // Agarrar la pos de los 3 gameobjects y los colores
        // y pasarselo a todos los materiales que existan
        // para que se actualice con la posicion de la luz
        
        foreach (Material material in materiales)
        {
            oldSpotLightColor = material.GetColor("_SpotLightColor");
            oldPointLightColor = material.GetColor("_PointLightColor");
            oldDirectionalLightDirection = material.GetVector("_DirectionalLightDirection_w");
        }

        // Directional light
        if (Input.GetKeyDown(KeyCode.Alpha1))
        {
            foreach (Material material in materiales)
            {
                if(!material.GetVector("_DirectionalLightDirection_w").Equals(new Vector4(0, 0, 0, 1))){
                    oldDirectionalLightDirection = material.GetVector("_DirectionalLightDirection_w");
                    material.SetVector("_DirectionalLightDirection_w", new Vector4(0, 0, 0, 1));
                }
                else
                {
                    material.SetVector("_DirectionalLightDirection_w", oldDirectionalLightDirection);
                }
            }
        }
        // Point light
        if (Input.GetKeyDown(KeyCode.Alpha2))
        {
            foreach (Material material in materiales)
            {
                if (material.GetColor("_PointLightColor") != Color.black)
                {
                    oldPointLightColor = material.GetColor("_PointLightColor");
                    material.SetColor("_PointLightColor", Color.black);
                }
                else
                    material.SetColor("_PointLightColor", oldPointLightColor);
            }
        }
        // SpotLight
        if (Input.GetKeyDown(KeyCode.Alpha3))
        {
            foreach (Material material in materiales)
            {
                if (material.GetColor("_SpotLightColor") != Color.black)
                {
                    oldSpotLightColor = material.GetColor("_SpotLightColor");
                    material.SetColor("_SpotLightColor", Color.black);
                }
                else
                    material.SetColor("_SpotLightColor", oldSpotLightColor);
            }
        }
    }
}
