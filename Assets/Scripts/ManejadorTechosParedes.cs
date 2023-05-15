using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ManejadorTechosParedes : MonoBehaviour
{

    public GameObject carpetaTechos;
    public GameObject carpetaParedes;

    public Boolean techoActivo;
    public Boolean paredesActivas;

    // Start is called before the first frame update
    void Start()
    {
        techoActivo = true;
        paredesActivas = true;
        carpetaTechos = GameObject.Find("Techo");
        carpetaParedes = GameObject.Find("Paredes");
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.T))
        {
            techoActivo = !techoActivo;
            carpetaTechos.SetActive(techoActivo);
            
        }
        if (Input.GetKeyDown(KeyCode.P))
        {
            paredesActivas = !paredesActivas;
            carpetaParedes.SetActive(paredesActivas);
        }
    }
}
