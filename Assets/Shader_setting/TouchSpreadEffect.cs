

using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using UnityEngine;
using UnityEngine.UI;

[Serializable]
struct Circle_info
{
    public Circle_info(Vector2 pos, float rad, Vector4 col)
    {
        CirclePosition = pos;
        CircleRadius = rad;
        CircleColor = col;
        
    }

    public Vector2 CirclePosition;
    public float CircleRadius;
    public Vector4 CircleColor;
    

}

public class TouchSpreadEffect : MonoBehaviour
{
    public Image targetImage;                // ������ UI �̹���
    public Sprite test_sprite;
    public Color targetColor = Color.red;    // Ÿ�� ����
    public Color replaceColor = Color.green; // ��ü�� ����
    [Range(0, 1)]
    public float tolerance = 0.1f;           // ��� ����

    private Material materialInstance;       // ��Ƽ���� �ν��Ͻ�
    private MaterialPropertyBlock mpb;
    private Vector2 touchPosition = Vector2.zero; // ��ġ ��ġ (UV ��ǥ)
    private float spreadRadius = 0.0f;       // ���� �ݰ�
    private bool spreading = false;          // ���� ����


    [Header("Dynamic Shader Settings")]
    List<Circle_info> Circles = new List<Circle_info>();
    

    private Circle_info temp_cir = new Circle_info();
    //Circle_info[] Circles;
    //bool[] is_on = { false, false, false, false, false, false, false, false, false, false };
    public Color randColor = Color.white;

    Vector4[] vec4s = {
        new Vector4(0, 1f, 0, 1),
        new Vector4(1f, 0, 0, 1),
        new Vector4(0, 0, 1f, 1),
        };

    Vector2 temp_vec2 = Vector2.zero;

    private int touchCount = 0;
    private int countiung = 0;

    void Start()
    {
        if (targetImage != null)
        {
            materialInstance = new Material(targetImage.material);
            targetImage.material = materialInstance;
            mpb = new MaterialPropertyBlock();
            
        }

        

        //Debug.Log(materialInstance);
        touchCount = 0;
        countiung = 0;

        // �ʱ� ���̴� �Ӽ� ����
        //UpdateShaderProperties();
    }

    void Update()
    {
        // ��ġ �Է� ����
        if (Input.GetMouseButtonDown(0))
        {
            //if(touchCount >= 10)
            //{
                //return;
            //
            //}
            Vector2 screenPosition = Input.mousePosition;
            //Debug.Log(screenPosition);
            RectTransformUtility.ScreenPointToLocalPointInRectangle(
                targetImage.rectTransform,
                screenPosition,
                null,
                out Vector2 localPoint
            );

            // ��ġ ��ġ�� UV ��ǥ�� ��ȯ
            Rect rect = targetImage.rectTransform.rect;
            touchPosition = new Vector2(
                (localPoint.x - rect.x) / rect.width,
                (localPoint.y - rect.y) / rect.height
            );

            //Debug.Log(touchPosition);
            temp_vec2.x = touchPosition.x;
            temp_vec2.y = touchPosition.y;
            temp_cir.CirclePosition = temp_vec2;
            temp_cir.CircleRadius = 0f;
            temp_cir.CircleColor = vec4s[touchCount % 3];

            Circles.Add(temp_cir);
            
            
            //is_on[touchCount] = true;
            

            spreadRadius = 0.0f; // �ݰ� �ʱ�ȭ
            spreading = true;    // ���� ����
            touchCount++;
            countiung++;
            UnityEngine.Debug.Log(countiung);
            UnityEngine.Debug.Log(Circles.Count);
        }

        // ���� ȿ�� ����
        if (countiung > 0)
        {
            spreadRadius += Time.deltaTime * 0.5f; // ���� �ӵ� ����
            if (!(Circles.Count != 0)) return;
            
            for(int j = Circles.Count - 1; j >= 0; j--)
            {
                
                if (Circles[j].CircleRadius > 1.5f)
                {
                    materialInstance.SetColor("_Color", Circles[j].CircleColor);
                    Circles.RemoveAt(j);
                    
                    countiung--;
                    UnityEngine.Debug.Log(countiung);
                    if (countiung == 0) return;
                    continue;
                }
                else
                {
                    //�̰� �ٲ�ߵ�... ������ �ʹ� ���� �Ͼ
                    temp_cir = Circles[j];
                    temp_cir.CircleRadius += (float)Time.deltaTime * 0.5f;
                    Circles[j] = temp_cir;
                }


                
            }

            

            UpdateShaderProperties();
        }
    }

    

    private void UpdateShaderProperties()
    {
        if (materialInstance != null)
        {
            //materialInstance.SetTexture("_MainTex", test_sprite.texture);
            //materialInstance.SetColor("_TargetColor", targetColor);
            //materialInstance.SetColor("_ReplaceColor", replaceColor);
            //materialInstance.SetFloat("_Tolerance", tolerance);
            //materialInstance.SetVector("_TouchPosition", touchPosition);
            //materialInstance.SetFloat("_SpreadRadius", spreadRadius);
            ComputeBuffer circlebuffer = new ComputeBuffer(Circles.Count, System.Runtime.InteropServices.Marshal.SizeOf(typeof(Circle_info)));
            circlebuffer.SetData(Circles.ToArray());

            materialInstance.SetBuffer("_Circles", circlebuffer);
            materialInstance.SetFloat("_CircleCount", Circles.Count);
            
            

            //materialInstance.ma
        }
    }
}
