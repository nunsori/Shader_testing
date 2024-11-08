

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
    public Image targetImage;                // 변경할 UI 이미지
    public Sprite test_sprite;
    public Color targetColor = Color.red;    // 타겟 색상
    public Color replaceColor = Color.green; // 대체할 색상
    [Range(0, 1)]
    public float tolerance = 0.1f;           // 허용 오차

    private Material materialInstance;       // 머티리얼 인스턴스
    private MaterialPropertyBlock mpb;
    private Vector2 touchPosition = Vector2.zero; // 터치 위치 (UV 좌표)
    private float spreadRadius = 0.0f;       // 퍼짐 반경
    private bool spreading = false;          // 퍼짐 상태


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

        // 초기 셰이더 속성 설정
        //UpdateShaderProperties();
    }

    void Update()
    {
        // 터치 입력 감지
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

            // 터치 위치를 UV 좌표로 변환
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
            

            spreadRadius = 0.0f; // 반경 초기화
            spreading = true;    // 퍼짐 시작
            touchCount++;
            countiung++;
            UnityEngine.Debug.Log(countiung);
            UnityEngine.Debug.Log(Circles.Count);
        }

        // 퍼짐 효과 적용
        if (countiung > 0)
        {
            spreadRadius += Time.deltaTime * 0.5f; // 퍼짐 속도 조절
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
                    //이거 바꿔야됨... 값복사 너무 많이 일어남
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
