using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Dado : MonoBehaviour
{
    private Vector3[] vertices;
    private GameObject objetoCuadrado;
    private Vector2[] uvs;
    private int[] triangulo;
    public Material newMaterial;

    // Start is called before the first frame update
    void Start()
    {
        objetoCuadrado = new GameObject("Dado");

        objetoCuadrado.AddComponent<MeshFilter>(); // agrega un manejador de mallas
        objetoCuadrado.GetComponent<MeshFilter>().mesh = new Mesh();
        objetoCuadrado.AddComponent<MeshRenderer>();


        CreateModel();

        objetoCuadrado.GetComponent<MeshRenderer>().material = newMaterial;

        objetoCuadrado.transform.position = new Vector3(2.124f, 0.1f, -0.489f);
        objetoCuadrado.transform.rotation = Quaternion.Euler(0, -23.253f, 0);
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void CreateModel()
    {
        //arreglo de posiciones de vertices
        vertices = new Vector3[]
        {
            //Cara 1
            new Vector3(0,0,0), //vertice 0
            new Vector3(1,0,0), //1
            new Vector3(0,0,1), //2
            new Vector3(1,0,1), //vertice 3
            //Cara2
            new Vector3(0,1,0),
            new Vector3(1,1,0),
            new Vector3(0,1,1),
            new Vector3(1,1,1), 
            //Cara3
            new Vector3(1,1,0),
            new Vector3(0,1,0),
            new Vector3(1,0,0),
            new Vector3(0,0,0),
            //Cara4
            new Vector3(1,1,1),
            new Vector3(0,1,1),
            new Vector3(1,0,1),
            new Vector3(0,0,1), 
            //Cara5
            new Vector3(0,0,0),
            new Vector3(0,1,0),
            new Vector3(0,1,1),
            new Vector3(0,0,1), 
            //Cara6
            new Vector3(1,0,0),
            new Vector3(1,1,0),
            new Vector3(1,1,1),
            new Vector3(1,0,1)
        };

        uvs = new Vector2[]
        {
            //Cara 1
            new Vector2(0,0.33f), //vertice 0
            new Vector2(0,0.66f), //1
            new Vector2(0.25f,0.33f), //2
            new Vector2(0.25f,0.66f), //vertice 3
            //Cara 2
            new Vector2(0.75f,0.33f),
            new Vector2(0.75f,0.66f),
            new Vector2(0.5f,0.33f),
            new Vector2(0.5f,0.66f),
            //Cara 3
            new Vector2(1,0.33f), //vertice 0
            new Vector2(0.75f,0.33f), //1
            
            new Vector2(1,0.66f), //vertice 3
            new Vector2(0.75f,0.66f), //2
            //Cara 4
            new Vector2(0.25f,0.33f),
            new Vector2(0.25f,0.66f),
            new Vector2(0.5f,0.33f),
            new Vector2(0.5f,0.66f),
            //Cara 5
            new Vector2(0.5f,1),
            new Vector2(0.25f,1),
            new Vector2(0.25f,0.66f),
            new Vector2(0.5f,0.66f),
            //Cara 6
            new Vector2(0.25f,0),
            new Vector2(0.25f,0.33f),
            new Vector2(0.5f,0.33f),
            new Vector2(0.5f,0)

        };

        triangulo = new int[]
        {
            //Cara 1
            0,1,2,
            1,3,2,
            //Cara 2
            5,4,6,
            5,6,7,
            //Cara 3
            8,11,9,
            8,10,11,
            //Cara 4
            14,12,15,
            15,12,13,
            //Cara 5
            16,18,17,
            16,19,18,
            //Cara 6
            22,23,20,
            20,21,22

        };

        objetoCuadrado.GetComponent<MeshFilter>().mesh.vertices = vertices;
        objetoCuadrado.GetComponent<MeshFilter>().mesh.triangles = triangulo;
        objetoCuadrado.GetComponent<MeshFilter>().mesh.uv = uvs;

        objetoCuadrado.transform.localScale = new Vector3(0.11f,0.11f,0.11f);
    }
}
